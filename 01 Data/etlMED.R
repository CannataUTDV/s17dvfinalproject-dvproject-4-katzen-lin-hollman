require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/preMED.csv"
PREmeddf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#CLEANUP
PREmeddf1 <- PREmeddf %>% dplyr::filter(!is.na(Greater_Risk_Data_Value)) %>% dplyr::filter(is.na(Greater_Risk_Data_Value_Footnote_Symbol)) %>% dplyr::filter(is.na(Greater_Risk_Data_Value_Footnote)) %>% dplyr::filter(is.na(Lesser_Risk_Data_Value_Footnote_Symbol)) %>% dplyr::filter(!is.na(Lesser_Risk_Data_Value)) %>% dplyr::filter(is.na(Lesser_Risk_Data_Value_Footnote)) %>% dplyr::select(-Data_Value_Symbol) %>% dplyr::select(-DataSource) %>% dplyr::select(-Data_Value_Type) %>% dplyr::select(-Greater_Risk_Data_Value_Footnote)	%>% dplyr::select(-Greater_Risk_Data_Value_Footnote_Symbol) %>% dplyr::select(-SexOfSexualContacts) 

PREmeddf2 <- PREmeddf1 %>% dplyr::select(-SexualIdentity)	%>% dplyr::select(-Lesser_Risk_Data_Value_Footnote_Symbol)	%>% dplyr::select(-Lesser_Risk_Data_Value_Footnote)	%>% dplyr::select(-StratID1) %>% dplyr::select(-StratID2)	%>% dplyr::select(-StratID3)	%>% dplyr::select(-StratID4)	%>% dplyr::select(-StratID5)	%>% dplyr::select(-StratID6) %>% dplyr::sample_n(10000)

#CREATE COLUMN: STATES (FULL)
PREmeddf3 <- PREmeddf2
listofab <- PREmeddf3$LocationAbbr
listofstates <- c()

for (every in listofab){
  if (is.na(every)){
    listofstates <- c(listofstates, "XX")
    next}
  
  if (every %in% state.abb){
    for (i in  (1:50)){
      print (i)
      if (every==state.abb[i]){
        listofstates <- c(listofstates, state.name[i])}}}
  else{
    listofstates <- c(listofstates, "XX")}
}

PREmeddf3["State"] <- NA
PREmeddf3$State <- listofstates
PREmeddf4 <- PREmeddf3 %>% dplyr::filter(State!="XX") %>% dplyr::select(-LocationDesc) %>% dplyr::select(-LocationAbbr)%>% dplyr::sample_n(5000)


write.csv(PREmeddf4, gsub("pre", "post", file_path), row.names=FALSE, na = "")
