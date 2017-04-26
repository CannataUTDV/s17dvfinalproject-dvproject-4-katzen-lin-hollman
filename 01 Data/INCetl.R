require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/INCpre.csv"
PREincomedf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[FILTER OUT UNNECESSARY COLUMNS]
df <- PREincomedf %>% plyr::rename(c("SummaryLevel" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("StateFIPS" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("GEOID" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("State" = "DEL" )) %>% dplyr::select(-DEL)

#[FILTER OUT DC AND PUERTO RICO]
df <- df %>% dplyr::filter(AreaName !='District of Columbia') %>% dplyr::filter(AreaName !='Puerto Rico') 

#[RENAME TO PRESERVE COLUMN]
df <- plyr::rename(df, c("AreaName" = "State" ))

#[SEPARATE DESIRED COLUMNS]
#[HEAD COUNT OF HOUSEHOLD INCOME BRACKETS]
dfA <- df %>% plyr::rename(c("State" = "B19001" )) %>%dplyr::select(B19001:B19001_017)%>% plyr::rename(c("B19001" = "State" ))

#[MEDIAN HOUSEHOLD INCOME BY RACE]
dfB <- plyr::rename(df, c("State" = "B19013" )) %>% dplyr::select(starts_with("B19013")) %>% dplyr::select(B19013:B19013I_001) %>% plyr::rename(c("B19013" = "State" ))

#[MEDIAN HOUSEHOLD INCOME BY AGE]
dfC <- plyr::rename(df, c("State" = "B19049" )) %>% dplyr::select(starts_with("B19049")) %>% dplyr::select(B19049:B19049_005) %>% plyr::rename(c("B19049" = "State" ))

#JOIN
df1 <- dplyr::left_join(dfA, dfB, by="State")
df2 <- dplyr::left_join(df1, dfC, by="State")

# create a new .csv file
write.csv(df2, gsub("pre", "post", file_path), row.names=FALSE, na = "")
