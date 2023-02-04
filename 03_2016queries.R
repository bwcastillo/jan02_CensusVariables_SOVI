

# Querying 2016 -----------------------------------------------------------
library(cancensus)
library(tidyverse)
options(cancensus.api_key = "CensusMapper_ec721325d8f0b73622eb6a175f8de05a")


listVar16 <- list_census_vectors("CA16")
listReg16 <- list_census_regions("CA16")

#Opening data
boundaries16<-st_read(paste0(here::here(),"input\\boundaries_16DA\\lda_000b16a_e\\lda_000b16a_e.shp"))
#REAL LOCATION: boundaries16<-sf::st_read("C:\\CEDEUS\\2022\\oct03_census2021\\input\\boundaries_16DA\\lda_000b16a_e\\lda_000b16a_e.shp")


# List variables 2016 ----------------------------------------------------------

vectors16<-c("v_CA16_401","v_CA16_404","v_CA16_406","v_CA16_385","v_CA16_388","v_CA16_391",
             "v_CA16_394","v_CA16_384","v_CA16_510","v_CA16_524","v_CA16_2222","v_CA16_2397",
             "v_CA16_2570","v_CA16_2573","v_CA16_2579","v_CA16_2582","v_CA16_3432","v_CA16_3822",
             "v_CA16_3957","v_CA16_3960","v_CA16_3963","v_CA16_3966","v_CA16_3969","v_CA16_3972",
             "v_CA16_3975","v_CA16_3978","v_CA16_3981","v_CA16_3984","v_CA16_3987","v_CA16_3990",
             "v_CA16_3993","v_CA16_3996","v_CA16_3855","v_CA16_3876","v_CA16_3861","v_CA16_3864",
             "v_CA16_3867","v_CA16_4838","v_CA16_4861","v_CA16_4872","v_CA16_4888","v_CA16_4895",
             "v_CA16_5054","v_CA16_5606","v_CA16_5609","v_CA16_5618","v_CA16_5801","v_CA16_6698",
             "v_CA16_410","v_CA16_497","v_CA16_4863")

nombres16 <- c("TOTPOP","TOTDWELL","POPDENSITY","BELOW15","WORKAGE","SENIOR","ABOVE85",
               "FEMALE","ONEPERSONHH","NOLANG","GOVTRANSFER","MEDHHINC","LOWINCOME",
               "LOWINCOME1","LOWINCWORKAGE","LOWINCSENIOR","RECENTIMMIGRANT","FIRSTGENERATION",
               "TOTVISMIN","SOUTHASIAN","CHINESE","BLACK","FILIPINO","LATINAMERICAN",
               "ARAB","SOUTHEASTASIAN","WESTASIAN","KOREAN","JAPANESE","VISMIN_NIE","MULTI_VINMIN",
               "NONVISMIN","ABORIGINAL","NON_ABORIGINAL","FRSTNATION","METIS","INUIT","RENTER",
               "CROWDHOME","REPAIRHOME","SHLTCOSTR","MEDHOMVAL","NODEGREE","UNEMPLOYED",
               "NILF","UNEMPRATE","PUBTRANSIT","MOVERS","APT5STORY","LONEPARENT","BUILT1960")

code_abvt16 <- data.frame(code=vectors16,abbrvtn=nombres16)


#TEST:WORKS
# query16da<-get_census(dataset='CA16',
#                       regions= list(DA=boundaries16$DAUID),
#                       vector=vectors16[1],
#                       level="DA")


# GETTING DATA ------------------------------------------------------------
query16da<-get_census(dataset='CA16',
                      regions= list(DA=boundaries16$DAUID[1:(56589/2)]),
                      vector=vectors16,
                      level="DA",
                      use_cache = T)

query16da_2<-get_census(dataset='CA16',
                        regions= list(DA=boundaries16$DAUID[(56589/2+1):56589]),
                        vector=vectors16,
                        level="DA",
                        use_cache = T)


#rm(boundaries16)

# Joining datasets --------------------------------------------------------

query16da<-rbind(query16da,query16da_2)

rm(query16da_2)

colnames(query16da)[12:62]

#Unifying names and col codes
# Testing
# code_abvt<-data.frame(code=query,abbrvtn=nombres)
# 
# target16<-sub(":.*", "", colnames(query16da))[12:62]
# 
# code_abvt16<-code_abvt16[match(target16,code_abvt16$code),]
# 
# colnames(query16da)[12:62] <- code_abvt16$abbrvtn




# Another scales ----------------------------------------------------------


query16cma<-get_census(dataset='CA16',
                       regions= list(CMA=unique(query16da$CMA_UID)[c(1,3:153)]),
                       vector=vectors16,
                       level="CMA",
                       use_cache = T)

query16csd<-get_census(dataset='CA16',
                       regions= list(CSD=unique(query16da$CSD_UID)),
                       vector=vectors16,
                       level="CSD",
                       use_cache = T)

query16ct<-get_census(dataset='CA16',
                      regions= list(CT=unique(query16da$CT_UID)),
                      vector=vectors16,
                      level="CT",
                      use_cache = T)

query16cd<-get_census(dataset='CA16',
                      regions= list(CT=unique(query16da$CD_UID)),
                      vector=vectors16,
                      level="CD",
                      use_cache = T)



# Changing colnames names ----------------------------------------------------------


# Creating a function -----------------------------------------------------
#tail(colnames(query21csd))
#tail(sub(":.*", "", colnames(query16csd)),n=51)  


col_format16<-function(x){
  code_abvt16
  target16<-tail(sub(":.*", "", colnames(x)),n=51)   #Change parameters according 16
  code_rplcmnt16<-code_abvt16[match(target16,code_abvt16$code),]
  print(code_rplcmnt16$code==target16)
  code_rplcmnt16$code
  a<-ncol(x)-51
  b<-a+51
  colnames(x)[a+1:b]<-code_rplcmnt16$abbrvtn
  x
  return(x)
}

query16cd_form<-col_format16(query16cd)
query16csd_form<-col_format16(query16csd)
query16cma_form<-col_format16(query16cma)
query16ct_form<-col_format16(query16ct)
query16da_form<-col_format16(query16da)


# Saving data -------------------------------------------------------------

#Formated 
write.csv(query16cd_form,"output/formated/csv16/query16cd_form.csv")
write.csv(query16csd_form,"output/formated/csv16/query16csd_form.csv")
write.csv(query16cma_form,"output/formated/csv16/query16cma_form.csv")
write.csv(query16ct_form,"output/formated/csv16/query16ct_form.csv")
write.csv(query16da_form,"output/formated/csv16/query16da_form.csv")

writexl::write_xlsx(query16cd_form,"output/formated/xlsx16/query16cd_form.xlsx")
writexl::write_xlsx(query16csd_form,"output/formated/xlsx16/query16csd_form.xlsx")
writexl::write_xlsx(query16cma_form,"output/formated/xlsx16/query16cma_form.xlsx")
writexl::write_xlsx(query16ct_form,"output/formated/xlsx16/query16ct_form.xlsx")
writexl::write_xlsx(query16da_form,"output/formated/xlsx16/query16da_form.xlsx")

#Raw
write.csv(query16cd,"output/rawdata/csv16/query16cd.csv")
write.csv(query16csd,"output/rawdata/csv16/query16csd.csv")
write.csv(query16cma,"output/rawdata/csv16/query16cma.csv")
write.csv(query16ct,"output/rawdata/csv16/query16ct.csv")
write.csv(query16da,"output/rawdata/csv16/query16da.csv")

writexl::write_xlsx(query16cd,"output/rawdata/xlsx16/query16cd.xlsx")
writexl::write_xlsx(query16csd,"output/rawdata/xlsx16/query16csd.xlsx")
writexl::write_xlsx(query16cma,"output/rawdata/xlsx16/query16cma.xlsx")
writexl::write_xlsx(query16ct,"output/rawdata/xlsx16/query16ct.xlsx")
writexl::write_xlsx(query16da,"output/rawdata/xlsx16/query16da.xlsx")

