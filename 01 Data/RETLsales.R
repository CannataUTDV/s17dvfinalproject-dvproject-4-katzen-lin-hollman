require(readr)
require(plyr)
require(dplyr)

# call .csv file (WD must be in 01 Data)
file_path = "../01 Data/PREsales.csv"
PREsalesdf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE, strip.white=TRUE)


df <- dplyr::select(PREsalesdf, one_of(c("FiscalYear", "CustomerName", "VendorName", "PurchaseAmount", "CustomerType", "CustomerCity", "CustomerState", "CustomerZIP", "CustomerGeolocation", "VendorContact", "PurchaseDescription", "OrderQuantity", "UnitPrice", "OrderDate", "ProductNumber", "BrandName", "OrderDate")))

# create a new .csv file
write.csv(df, gsub("PRE","POST", file_path), row.names=FALSE, na = "")

