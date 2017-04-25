require(readr)
require(plyr)
require(dplyr)

# call .csv file (WD must be in 01 Data)
file_path = "../01 Data/PREincome.csv"
PREincomedf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#rename zip
df <- plyr::rename(PREincomedf, c("ZCTA" = "ZIP" ))

#FILTER OUT DEL
df <- plyr::rename(df, c("SummaryLevel" = "DEL" ))
df <- dplyr::select(df, -DEL)

df <- plyr::rename(df, c("US" = "DEL" ))
df <- dplyr::select(df, -DEL)

df <- plyr::rename(df, c("GEOID" = "DEL" ))
df <- dplyr::select(df, -DEL)

df <- plyr::rename(df, c("AreaName" = "DEL" ))
df <- dplyr::select(df, -DEL)

# [SELECT TX]
df <- dplyr::filter(df, ZIP>75000)
df <- dplyr::filter(df, ZIP<80000)
    
# [SELECT COLUMNS] Filters out everything but ..... (and new area name too)

dfA <- plyr::rename(df, c("ZIP" = "B19001" ))
dfA <- dplyr::select(dfA, B19001:B19001D_017)
dfA <- plyr::rename(dfA, c("B19001" = "ZIP" ))


dfB <- plyr::rename(df, c("ZIP" = "B19061" ))
dfB <- dplyr::select(dfB, starts_with("B1906"))
dfB <- dplyr::select(dfB, B19061:B19069_001)
dfB <- plyr::rename(dfB, c("B19061" = "ZIP" ))

dfC <- plyr::rename(df, c("ZIP" = "B19083" ))
dfC <- dplyr::select(dfC, starts_with("B19083"))
dfC <- dplyr::select(dfC, B19083:B19083_001)
dfC <- plyr::rename(dfC, c("B19083" = "ZIP" ))

dfD <- plyr::rename(df, c("ZIP" = "B19301" ))
dfD <- dplyr::select(dfD, starts_with("B193"))
dfD <- dplyr::select(dfD, B19301:B19313I_001)
dfD <- plyr::rename(dfD, c("B19301" = "ZIP" ))

#dfA <- dplyr::select(df, B19001_001:B19001D_017)
#dfB <- dplyr::select(df, B19061_001:B19069_001)
#dfC <- dplyr::select(df, B19083_001)
#dfD <- dplyr::select(df, B19301_001:B19313I_001)

# JOIN
df1 <- dplyr::left_join(dfA, dfB, by="ZIP")
df2 <- dplyr::left_join(df1, dfC, by="ZIP")
df3 <- dplyr::left_join(df2, dfD, by="ZIP")


# create a new .csv file
write.csv(df3, gsub("PRE", "POST", file_path), row.names=FALSE, na = "")

