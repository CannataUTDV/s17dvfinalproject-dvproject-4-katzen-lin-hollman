require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/EDUpre.csv"
PREdf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[FILTER OUT UNNECESSARY COLUMNS]
df <- PREdf %>% plyr::rename(c("SummaryLevel" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("StateFIPS" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("GEOID" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("State" = "DEL" )) %>% dplyr::select(-DEL)

#[FILTER OUT DC AND PUERTO RICO]
df <- df %>% dplyr::filter(AreaName !='District of Columbia') %>% dplyr::filter(AreaName !='Puerto Rico') 

#[RENAME TO PRESERVE COLUMN]
df <- plyr::rename(df, c("AreaName" = "State" ))

#[SEPARATE DESIRED COLUMNS]
#[EDUCATIONAL ATTAINMENT BY AGE, SEX, AND RACE]
dfA <- plyr::rename(df, c("State" = "C15002" )) %>% dplyr::select(starts_with("C15002")) %>% dplyr::select(C15002:C15002E_011) %>% plyr::rename(c("C15002" = "State" ))

#[MEDIAN HOUSEHOLD INCOME BY RACE]
dfB <- plyr::rename(df, c("State" = "B1501" )) %>% dplyr::select(starts_with("B1501")) %>% dplyr::select(B1501:B15012_010) %>% plyr::rename(c("B1501" = "State" ))

#JOIN
df1 <- dplyr::left_join(dfA, dfB, by="State")

# create a new .csv file
write.csv(df1, gsub("pre", "post", file_path), row.names=FALSE, na = "")
