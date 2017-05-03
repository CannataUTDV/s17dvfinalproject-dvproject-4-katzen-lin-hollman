require(readr)
require(plyr)
require(dplyr)

#[CALL CSV]
file_path = "../01 Data/preMED.csv"
PREmeddf <- readr::read_csv(file_path)
options(stringsAsFactors = FALSE)

#[STRIP NONUSED COLUMNS]
PREmeddf1 <- PREmeddf %>% dplyr::filter(!is.na(Greater_Risk_Data_Value)) %>% dplyr::filter(is.na(Greater_Risk_Data_Value_Footnote_Symbol)) %>% dplyr::filter(is.na(Greater_Risk_Data_Value_Footnote)) %>% dplyr::filter(is.na(Lesser_Risk_Data_Value_Footnote_Symbol)) %>% dplyr::filter(!is.na(Lesser_Risk_Data_Value)) %>% dplyr::filter(is.na(Lesser_Risk_Data_Value_Footnote)) %>% dplyr::select(-Data_Value_Symbol) %>% dplyr::select(-DataSource) %>% dplyr::select(-Data_Value_Type) %>% dplyr::select(-Greater_Risk_Data_Value_Footnote)	%>% dplyr::select(-Greater_Risk_Data_Value_Footnote_Symbol) %>% dplyr::select(-SexOfSexualContacts) %>% dplyr::select(-SexualIdentity)	%>% dplyr::select(-Lesser_Risk_Data_Value_Footnote_Symbol)	%>% dplyr::select(-Lesser_Risk_Data_Value_Footnote)	%>% dplyr::select(-StratID1) %>% dplyr::select(-StratID2)	%>% dplyr::select(-StratID3)	%>% dplyr::select(-StratID4)	%>% dplyr::select(-StratID5)	%>% dplyr::select(-StratID6) %>% dplyr::select(-TopicId) %>% dplyr::select(-SubTopicID) %>% dplyr::select(-QuestionCode) %>% dplyr::select(-StratificationType) 

#[SEPARATE DESIRED COLUMNS]
PREmeddf2 <- PREmeddf1
marijuana <- dplyr::filter(PREmeddf2, ShortQuestionText=="Current marijuana use")
alcohol <- dplyr::filter(PREmeddf2, ShortQuestionText=="Current alcohol use")
cigarette <- dplyr::filter(PREmeddf2, ShortQuestionText=="Current cigarette use")
suicide <- dplyr::filter(PREmeddf2, ShortQuestionText=="Suicide consideration")
fighting <- dplyr::filter(PREmeddf2, ShortQuestionText=="Physical fighting")
weight <- dplyr::filter(PREmeddf2, ShortQuestionText=="Weight loss")

#[JOIN]
joinedgroups <- dplyr::bind_rows(marijuana, alcohol)
joinedgroups <- dplyr::bind_rows(joinedgroups, cigarette)
joinedgroups <- dplyr::bind_rows(joinedgroups, suicide)
joinedgroups <- dplyr::bind_rows(joinedgroups, fighting)
joinedgroups <- dplyr::bind_rows(joinedgroups, weight)

#CREATE COLUMN: STATES (FULL)
PREmeddf3 <- joinedgroups
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
PREmeddf4 <- PREmeddf3 %>% dplyr::filter(State!="XX") %>% dplyr::select(-LocationDesc) %>% dplyr::select(-LocationAbbr)
PREmeddf5 <- PREmeddf4
PREmeddf5$GeoLocation <- gsub("[(]", "", PREmeddf5$GeoLocation)  
PREmeddf5$GeoLocation <- gsub("[)]", "", PREmeddf5$GeoLocation)  
PREmeddf5 <- tidyr::separate(PREmeddf5, GeoLocation, into = c("Latitude", "Longitude"), sep=",")

write.csv(PREmeddf5, gsub("pre", "post", file_path), row.names=TRUE, na = "")
