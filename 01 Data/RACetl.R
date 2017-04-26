require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/RACpre.csv"
PREdf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[FILTER OUT UNNECESSARY COLUMNS]
df <- PREdf %>% plyr::rename(c("SummaryLevel" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("StateFIPS" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("GEOID" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("State" = "DEL" )) %>% dplyr::select(-DEL)

#[FILTER OUT DC AND PUERTO RICO]
df <- df %>% dplyr::filter(AreaName !='District of Columbia') %>% dplyr::filter(AreaName !='Puerto Rico') 

#[RENAME TO PRESERVE COLUMN]
df <- plyr::rename(df, c("AreaName" = "State" ))

#[RACE FOR TOTAL POPULATION]
dfA <- df %>% plyr::rename(c("State" = "B02001" )) %>% dplyr::select(starts_with("B02001")) %>% dplyr::select(B02001:B02001_007)

dfA <- dplyr::rename(dfA, State = B02001, pop.total = B02001_001, pop.white = B02001_002, pop.black = B02001_003, pop.americanindian = B02001_004, pop.asian = B02001_005, pop.pacificislander = B02001_006, pop.other = B02001_007)


# create a new .csv file
write.csv(dfA, gsub("pre", "post", file_path), row.names=FALSE, na = "")
