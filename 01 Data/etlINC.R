require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/preINC.csv"
PREincomedf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[FILTER OUT UNNECESSARY COLUMNS]
df <- PREincomedf %>% plyr::rename(c("SummaryLevel" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("StateFIPS" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("GEOID" = "DEL" )) %>% dplyr::select(-DEL) %>% plyr::rename(c("State" = "DEL" )) %>% dplyr::select(-DEL)

#[FILTER OUT DC AND PUERTO RICO]
df <- df %>% dplyr::filter(AreaName !='District of Columbia') %>% dplyr::filter(AreaName !='Puerto Rico') 

#[RENAME TO PRESERVE COLUMN]
df <- plyr::rename(df, c("AreaName" = "State" ))

#[SEPARATE DESIRED COLUMNS]
#[HEAD COUNT OF HOUSEHOLD INCOME BRACKETS] (if you want it)
#dfA <- df %>% plyr::rename(c("State" = "B19001" )) %>%dplyr::select(B19001:B19001_017)%>% plyr::rename(c("B19001" = "State" ))

#[MEDIAN HOUSEHOLD INCOME BY RACE]
dfB <- plyr::rename(df, c("State" = "B19013" )) %>% dplyr::select(starts_with("B19013")) %>% dplyr::select(B19013:B19013F_001) %>% plyr::rename(c("B19013" = "State" ))

#[MEDIAN HOUSEHOLD INCOME BY AGE]
dfC <- plyr::rename(df, c("State" = "B19049" )) %>% dplyr::select(starts_with("B19049")) %>% dplyr::select(B19049:B19049_005) %>% plyr::rename(c("B19049" = "State" ))

#JOIN (if you want it)
df1 <- dplyr::left_join(dfB, dfC, by="State")
#df2 <- dplyr::left_join(df1, dfC, by="State")

# if you want it
#dfZ <- dplyr::rename(df2, inc.counttotal = B19001_001, inc.lessthan10k = B19001_002	, inc.10to15k = B19001_003	, inc.15to20k = B19001_004	, inc.20to25k = B19001_005	, inc.25to30k = B19001_006	, inc.30to35k = B19001_007	, inc.35to40k = B19001_008	, inc.40to45k = B19001_009	, inc.45to50k = B19001_010	, inc.50to60k = B19001_011	, inc.60to75k = B19001_012	, inc.75to100k = B19001_013	, inc.100kto125k = B19001_014	, inc.125to150k = B19001_015	, inc.150to200k = B19001_016, inc.200kmore = B19001_017) 

dfZ <- dplyr::rename(df1,med.inc.total = B19013_001	, med.inc.white = B19013A_001, med.inc.black = B19013B_001	, med.inc.americanindian = B19013C_001, med.inc.asian = B19013D_001	, med.inc.pacificislander = B19013E_001, med.inc.other = B19013F_001, med.inc.age.total = B19049_001, med.inc.age.under25 = B19049_002, med.inc.age.25to44 = B19049_003, med.inc.age.45to64 = B19049_004, med.inc.age.65over = B19049_005)

# create a new .csv file
write.csv(dfZ, gsub("pre", "post", file_path), row.names=FALSE, na = "")
