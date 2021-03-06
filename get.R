library(RCurl)
library(XML)

# Some (2) files are Word documents
# The "Palo_Verde_Union_Elementary_(DOC).pdf" is not however.
#  That is an odd file with a file magic number of 193204,

# We get 110 HTML files.
# 56 of these are from drive.google.com that gets downloaded as HTML not PDF.
# out[grep("drive.google", d$u)] %in% gsub("file '|'$", "", html)
# html is defined in checkPDFXML.R

u = "https://www.cde.ca.gov/fg/aa/lc/calcaplinks1718.asp"
tt = getURLContent(u)
doc = htmlParse(I(tt))

td = getNodeSet(doc, "//table/tr/td[2]")
lnks = structure(sapply(td, function(x) xmlGetAttr(x[[1]], "href", "")), names = sapply(td, xmlValue))
names(lnks) = gsub("\\(PDF\\)", "", names(lnks))

county = xpathSApply(doc, "//table/tr/td[1]", xmlValue)
d = data.frame(district = names(lnks), url = lnks, county = county, stringsAsFactors = FALSE)

d$district = gsub("\\r\\n", " ", d$district)
d$district = gsub(" +", " ", d$district)

#d$u = gsub("%20", " ", d$u)

#  two links combined
i = which(sapply(gregexpr("http", d$u), length) > 1)
m = lapply(strsplit(d$u[i], "http"), function(x) setdiff(paste0("http", x), "http"))
d$u[i] = sapply(m, `[`, 1)
w = d$u[i+1] == ""
if(any(w))
  d$u[ (i+1)[w] ] = sapply(m[w], `[`, 2)


out = file.path("2017_18", paste0(gsub(" ", "_", XML:::trim(d$district)), ".pdf"))
ans = mapply(function(u, f) {
        if(!file.exists(f))
            try(download.file(u, f))
        else
            0L
       }, d$u, out)

# Which ones didn't we get
b = !(file.exists(out))
table(b)

d$got = !b
saveRDS(d, "2017_18Status.rds")

# See checkPDFXML.R for the file types.


#########

setdiff(d[b, 2], "")

###############

dw = lapply(setdiff(d[b, 2], ""), function(x) try(download.file(x, "bob.pdf")))
table(sapply(dw, class))


