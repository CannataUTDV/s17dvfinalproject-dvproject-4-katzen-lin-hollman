require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/preEDU.csv"
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

#[FIELDS OF BACHELORS] if you want it
#dfB <- plyr::rename(df, c("State" = "B1501" )) %>% dplyr::select(starts_with("B1501")) %>% dplyr::select(B1501:B15012_010) %>% plyr::rename(c("B1501" = "State" ))

#JOIN
#df1 <- dplyr::left_join(dfA, dfB, by="State")

dfA <- dplyr::rename(dfA, 
edu.white = C15002A_001,	
edu.white.male = C15002A_002,
edu.white.male.lessGED = C15002A_003,
edu.white.male.GED = C15002A_004,
edu.white.male.somecollege = C15002A_005,
edu.white.male.bachelors = C15002A_006,	
edu.white.female = C15002A_007,	
edu.white.female.lessGED = C15002A_008,	
edu.white.female.GED = C15002A_009,	
edu.white.female.somecollege = C15002A_010,	
edu.white.female.bachelors = C15002A_011,	
edu.black = C15002B_001,	
edu.black.male = C15002B_002,	
edu.black.male.lessGED = C15002B_003,	
edu.black.male.GED = C15002B_004,	
edu.black.male.somecollege = C15002B_005,	
edu.black.male.bachelors = C15002B_006,	
edu.black.female = C15002B_007,	
edu.black.female.lessGED = C15002B_008,	
edu.black.female.GED = C15002B_009,	
edu.black.female.somecollege = C15002B_010,	
edu.black.female.bachelors = C15002B_011,	
edu.americanindian = C15002C_001,	
edu.americanindian.male = C15002C_002,	
edu.americanindian.male.lessGED = C15002C_003,	
edu.americanindian.male.GED = C15002C_004,	
edu.americanindian.male.somecollege = C15002C_005,
edu.americanindian.male.bachelors = C15002C_006,
edu.americanindian.female = C15002C_007,
edu.americanindian.female.lessGED = C15002C_008,
edu.americanindian.female.GED =	C15002C_009,
edu.americanindian.female.somecollege = C15002C_010,
edu.americanindian.female.bachelors = C15002C_011,
edu.asian = C15002D_001,	
edu.asian.male = C15002D_002,	
edu.asian.male.lessGED = C15002D_003,	
edu.asian.male.GED = C15002D_004,	
edu.asian.male.somecollege = C15002D_005,
edu.asian.male.bachelors = C15002D_006,
edu.asian.female = C15002D_007,
edu.asian.female.lessGED = C15002D_008,
edu.asian.female.GED =	C15002D_009,
edu.asian.female.somecollege = C15002D_010,
edu.asian.female.bachelors = C15002D_011,
edu.pacificislander = C15002E_001,	
edu.pacificislander.male = C15002E_002,	
edu.pacificislander.male.lessGED = C15002E_003,	
edu.pacificislander.male.GED = C15002E_004,	
edu.pacificislander.male.somecollege = C15002E_005,
edu.pacificislander.male.bachelors = C15002E_006,
edu.pacificislander.female = C15002E_007,
edu.pacificislander.female.lessGED = C15002E_008,
edu.pacificislander.female.GED =	C15002E_009,
edu.pacificislander.female.somecollege = C15002E_010,
edu.pacificislander.female.bachelors = C15002E_011)

# if you want itB15011_001 B15011_002 B15011_003	B15011_004	B15011_005	B15011_006	B15011_007	B15011_008	B15011_009	B15011_010	B15011_011	B15011_012	B15011_013	B15011_014	B15011_015	B15011_016	B15011_017	B15011_018	B15011_019	B15011_020	B15011_021	B15011_022	B15011_023	B15011_024	B15011_025	B15011_026	B15011_027	B15011_028	B15011_029	B15011_030	B15011_031	B15011_032	B15011_033	B15011_034	B15011_035	B15011_036	B15011_037	B15011_038	B15011_039	B15012_001	B15012_002	B15012_003	B15012_004	B15012_005	B15012_006	B15012_007	B15012_008	B15012_009	B15012_010


# create a new .csv file
write.csv(dfA, gsub("pre", "post", file_path), row.names=FALSE, na = "")
