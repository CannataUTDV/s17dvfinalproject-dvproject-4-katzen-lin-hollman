require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/preEMP.csv"
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


#RENAME
dfF <- dplyr::rename(df2, emp.edu.total = B23006_001, 
emp.lessGED = B23006_002,
emp.lessGED.inlaborpool = B23006_003,
emp.lessGED.inlaborpool.armedforces = B23006_004,	
emp.lessGED.inlaborpool.civilian = B23006_005,
emp.lessGED.inlaborpool.civilian.employed = B23006_006,
emp.lessGED.inlaborpool.civilian.unemployed = B23006_007,
emp.lessGED.outlaborpool= B23006_008,
emp.GED = B23006_009,
emp.GED.inlaborpool = B23006_010,
emp.GED.inlaborpool.armedforces = B23006_011,	
emp.GED.inlaborpool.civilian = B23006_012,
emp.GED.inlaborpool.civilian.employed = B23006_013,
emp.GED.inlaborpool.civilian.unemployed = B23006_014,
emp.GED.outlaborpool= B23006_015,
emp.somecollege = B23006_016,
emp.somecollege.inlaborpool = B23006_017,
emp.somecollege.inlaborpool.armedforces = B23006_018,	
emp.somecollege.inlaborpool.civilian = B23006_019,
emp.somecollege.inlaborpool.civilian.employed = B23006_020,
emp.somecollege.inlaborpool.civilian.unemployed = B23006_021,
emp.somecollege.outlaborpool= B23006_022,
emp.bachelors = B23006_023,
emp.bachelors.inlaborpool = B23006_024,
emp.bachelors.inlaborpool.armedforces = B23006_025,	
emp.bachelors.inlaborpool.civilian = B23006_026,
emp.bachelors.inlaborpool.civilian.employed = B23006_027,
emp.bachelors.inlaborpool.civilian.unemployed = B23006_028,
emp.bachelors.outlaborpool= B23006_029,
emp.meanannualhrsworked = B23020_001,
emp.meanannualhrsworked.male = B23020_002,
emp.meanannualhrsworked.female = B23020_003,	
emp.status.total = B23025_001,
emp.status.inlaborpool = B23025_002,
emp.status.inlaborpool.civilian = B23025_003,	
emp.status.inlaborpool.civilian.employed = B23025_004,	
emp.status.inlaborpool.civilian.unemployed = B23025_005,	
emp.status.inlaborpool.armedforces = 	B23025_006,	
emp.status.outlaborpool = B23025_007)




# create a new .csv file
write.csv(dfF, gsub("pre", "post", file_path), row.names=FALSE, na = "")
