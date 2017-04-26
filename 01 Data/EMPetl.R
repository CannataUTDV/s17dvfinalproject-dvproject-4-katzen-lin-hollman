require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/EMPpre.csv"
PREdf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[FILTER OUT UNNECESSARY COLUMNS]
df <- PREdf %>% plyr::rename(c("SummaryLevel" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("StateFIPS" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("GEOID" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("State" = "DEL" )) %>% dplyr::select(-DEL)

#[FILTER OUT DC AND PUERTO RICO]
df <- df %>% dplyr::filter(AreaName !='District of Columbia') %>% dplyr::filter(AreaName !='Puerto Rico') 

#[RENAME TO PRESERVE COLUMN]
df <- plyr::rename(df, c("AreaName" = "State" ))

#[SEPARATE DESIRED COLUMNS]
#[EMPLOYMENT STATUS BY AGE, SEX, AND LABOR FORCE GROUPING]
dfA <- plyr::rename(df, c("State" = "B23006" )) %>% dplyr::select(starts_with("B23006")) %>% dplyr::select(B23006:B23006_029) %>% plyr::rename(c("B23006" = "State" ))

#[MEAN HOURS WORKED BY SEX]
dfB <- plyr::rename(df, c("State" = "B23020" )) %>% dplyr::select(starts_with("B23020")) %>% dplyr::select(B23020:B23020_003) %>% plyr::rename(c("B23020" = "State" ))

#[EMPLOYMENT STATUS BY LABOR FORCE GROUPING]
dfC <- plyr::rename(df, c("State" = "B23025" )) %>% dplyr::select(starts_with("B23025")) %>% dplyr::select(B23025:B23025_007) %>% plyr::rename(c("B23025" = "State" ))

#JOIN
df1 <- dplyr::left_join(dfA, dfB, by="State")
df2 <- dplyr::left_join(df1, dfC, by="State")

# create a new .csv file
write.csv(df2, gsub("pre", "post", file_path), row.names=FALSE, na = "")
