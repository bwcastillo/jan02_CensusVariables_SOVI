
# Seeing Cancensus dictionary ---------------------------------------------
library(sf)
library(cancensus)
library(tidyverse)

options(cancensus.api_key = "CensusMapper_ec721325d8f0b73622eb6a175f8de05a")
set_cancensus_cache_path("C:\\CEDEUS\\2022\\oct03_census2021\\cache")
listVar21 <- list_census_vectors("CA21")
listReg21 <- list_census_regions("CA21")

unique(listReg21$level)

# Open boundaries ---------------------------------------------------------
boundaries21<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21DA\\lda_000b21a_e\\lda_000b21a_e.shp")
boundaries21cd<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21CD\\lcd_000b21a_e\\lcd_000b21a_e.shp")
boundaries21cma<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21CMA&CA\\lcma000b21a_e\\lcma000b21a_e.shp")
boundaries21csd<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21CSD\\lcsd000b21a_e\\lcsd000b21a_e.shp")
boundaries21ct<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21CT\\lct_000b21a_e\\lct_000b21a_e.shp")
boundaries21pr<-st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_21PR\\lpr_000b21a_e\\lpr_000b21a_e.shp")


# List variables of interest ----------------------------------------------
query<-paste0("v_CA21_",
              as.character(c(1,4,6,11,68,251,326,10,553,1156,581,906,1085,1088,
                             1094,1097,4431,4821,4875,4878,4881,4884,4887,4893,
                             4890,4896,4899,4902,4905,4908,4911,4914,4210,4335,
                             4216,4239,4262,4274,4290,4311,5820,6501,6504,7644,
                             5751,440,528,4264))
              )


# Querying ----------------------------------------------------------------


# DA ----------------------------------------------------------------------
#Non-spatial
query21da<-get_census(dataset='CA21',
                       regions= list(DA=boundaries21$DAUID[1:(57932/2)]),
                       vector=query,
                       level="DA",
                       use_cache = T)

query21da_2<-get_census(dataset='CA21',
                       regions= list(DA=boundaries21$DAUID[(57932/2+1):57932]),
                       vector=query,
                       level="DA",
                       use_cache = T)

#Spatial #1
query21da_sf<-get_census(dataset='CA21',
              regions= list(DA=boundaries21$DAUID[1:(57932/4)]),
              vector=query,
              level="DA",
              geo_format = "sf")

#Spatial #2

query21da_sf2<-get_census(dataset='CA21',
                        regions= list(DA=boundaries21$DAUID[(57932/4+1):28966]),#(57932/4*2)]),
                        vector=query,
                        level="DA",
                        geo_format = 'sf')


#Spatial #3 MAKING Troubles

query21da_sf3<-list()
for (i in 28967:43450){a<-get_census(dataset='CA21',
                                  regions= list(DA=boundaries21$DAUID[i]),
                                  vector=query,
                                  level="DA",
                                  geo_format = 'sf',
                                  use_cache = F)
                        query21da_sf3[[i]]<-a
                        }
       
query21da_sf3<-get_census(dataset='CA21',
                        regions= list(DA=boundaries21$DAUID[(28966+1):43450]),
                        vector=query,
                        level="DA",
                        geo_format = 'sf',
                        use_cache = F)

#Spatial #4 MAKING Troubles

query21da_sf3<-get_census(dataset='CA21',
                        regions= list(DA=boundaries21$DAUID[43451:57932]),
                        vector=query,
                        level="DA",
                        geo_format = 'sf')

#Not available database census forward sortation areas :
#https://open.canada.ca/data/en/dataset/750e6035-adf8-4426-966f-4c25b12a999e


rm(boundaries21)
# Joining datasets --------------------------------------------------------

query21da<-rbind(query21da,query21da_2)

rm(query21da_2)

# Changing names -----------------------------------------------------------

nombres<-c("TOTPOP","TOTDWELL","POPDENSITY","BELOW15","WORKAGE","SENIOR",
           "ABOVE85","FEMALE","ONEPERSONHH","NOLANG","GOVTRANSFER","MEDHHINC",
           "LOWINCOME","LOWINCOME1","LOWINCWORKAGE","LOWINCSENIOR",
           "RECENTIMMIGRANT","FIRSTGENERATION","TOTVISMIN","SOUTHASIAN",
           "CHINESE","BLACK","FILIPINO","LATINAMERICAN","ARAB","SOUTHEASTASIAN",
           "WESTASIAN","KOREAN","JAPANESE","VISMIN_NIE","MULTI_VINMIN",
           "NONVISMIN","FRSTNATION","METIS","INUIT","RENTER","CROWDHOME",
           "REPAIRHOME","SHLTCOSTR","MEDHOMVAL","NODEGREE","UNEMPLOYED","NILF",
           "PUBTRANSIT","MOVERS","APT5STORY","LONEPARENT","BUILT1960")


#Unifying names and col codes

code_abvt<-data.frame(code=query,abbrvtn=nombres)

target<-sub(":.*", "", colnames(query21da))[12:59]

code_abvt<-code_abvt[match(target,code_abvt$code),]

#Veryifing that the reorder is correct

code_abvt$code==target

# Changing colnames -------------------------------------------------------
liton_dataset<-query21da

#Back up query
colnames(liton_dataset)[12:59]<-code_abvt$abbrvtn

liton_dataset


# Selecting for Kasra and Sina CI paper -----------------------------------

query21da_ks <- read.csv("output/formated/csv/query21da_form.csv")

colnames(query21da_ks)[2:12]

c("TOTPOP","TOTDWELL","POPDENSITY","BELOW15","SENIOR","FEMALE","ONEPERSONHH",
  "NOLANG","LOWINCOME","LOWINCSENIOR","LONEPARENT","MEDHHINC","APT5STORY")


query21da_ks <- query21da_ks[,c(colnames(query21da_ks)[2:12],"TOTPOP","TOTDWELL","POPDENSITY","BELOW15","SENIOR","FEMALE","ONEPERSONHH",
               "NOLANG","LOWINCOME","LOWINCSENIOR","LONEPARENT","MEDHHINC","APT5STORY")]


write.csv(query21da_ks,"C:\\CEDEUS\\2022\\dec01_bbddSina_KasraPaper\\output\\3csv\\query21da_100.csv")
writexl::write_xlsx(query21da_ks,"C:\\CEDEUS\\2022\\dec01_bbddSina_KasraPaper\\output\\2excel\\query21da_100.xlsx")