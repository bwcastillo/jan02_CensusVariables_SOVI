
# Seeing Cancensus dictionary ---------------------------------------------
library(sf)
library(cancensus)
library(tidyverse)

options(cancensus.api_key = "youAPIKEY")
set_cancensus_cache_path(paste0(here::here(),"\\cache"))

listVar21 <- list_census_vectors("CA21")
listReg21 <- list_census_regions("CA21")

unique(listReg21$level)

# Open boundaries ---------------------------------------------------------

boundaries21<-st_read(paste0(here::here(),"\\input\\boundaries_21DA\\lda_000b21a_e\\lda_000b21a_e.shp"))
boundaries21cd<-st_read(paste0(here::here(),"\\input\\boundaries_21CD\\lcd_000b21a_e\\lcd_000b21a_e.shp"))
boundaries21cma<-st_read(paste0(here::here(),"input\\boundaries_21CMA&CA\\lcma000b21a_e\\lcma000b21a_e.shp"))
boundaries21csd<-st_read(paste0(here::here(),"\\input\\boundaries_21CSD\\lcsd000b21a_e\\lcsd000b21a_e.shp"))
boundaries21ct<-st_read(paste0(here::here(),"\\input\\boundaries_21CT\\lct_000b21a_e\\lct_000b21a_e.shp"))
boundaries21pr<-st_read(paste0(here::here(),"\\input\\boundaries_21PR\\lpr_000b21a_e\\lpr_000b21a_e.shp"))



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

rm(boundaries21)

# Joining datasets --------------------------------------------------------

query21da<-rbind(query21da,query21da_2)

rm(query21da_2)



# #Testing how to join names and col codes --------------------------------


# Changing names 

nombres<-c("TOTPOP","TOTDWELL","POPDENSITY","BELOW15","WORKAGE","SENIOR",
           "ABOVE85","FEMALE","ONEPERSONHH","NOLANG","GOVTRANSFER","MEDHHINC",
           "LOWINCOME","LOWINCOME1","LOWINCWORKAGE","LOWINCSENIOR",
           "RECENTIMMIGRANT","FIRSTGENERATION","TOTVISMIN","SOUTHASIAN",
           "CHINESE","BLACK","FILIPINO","LATINAMERICAN","ARAB","SOUTHEASTASIAN",
           "WESTASIAN","KOREAN","JAPANESE","VISMIN_NIE","MULTI_VINMIN",
           "NONVISMIN","FRSTNATION","METIS","INUIT","RENTER","CROWDHOME",
           "REPAIRHOME","SHLTCOSTR","MEDHOMVAL","NODEGREE","UNEMPLOYED","NILF",
           "PUBTRANSIT","MOVERS","APT5STORY","LONEPARENT","BUILT1960")


code_abvt<-data.frame(code=query,abbrvtn=nombres)

target<-sub(":.*", "", colnames(query21da))[12:59]

code_abvt<-code_abvt[match(target,code_abvt$code),]

#Verifying that the reorder is correct

code_abvt$code==target

