# Extracting SoVI variables
### This is a small documentation to know how to get the variables to create a Social Vulnerability Index.

The variables used to generate this index are extracted from **Canada Census** database, through the **[CanCensus](https://mountainmath.github.io/cancensus/)** R-package. If you want to use this library, you should to create an account and create an API Key in the link referenced. 

The extraction of these variables were done in the 2016 Canadian Census, but also is possible extract the variables for the 2021 Census. Each one of these variables
has its respective code in CanCensus.

|N°| Factor | Variable Description|  Variable Code Abbreviation|  CanCensus Code 2016  | CanCensus Code 2021 |
|:------------- |:-------------:|:-------------:|:-------------:|:-------------:| -----:|
|1| Social | One-person households (%)| ONEPERHH | v_CA16_510|  v_CA21_553|
|2| Social | Official language knowledge (People who know neither English nor French) %      |  NOLANG | v_CA16_524|v_CA21_1156 |
|3| Social | Inhabitants with age 15 or older with no certificate/diploma/degree (%)   |    NODEGREE | v_CA16_5054|v_CA21_5820 |
|4| Social | Lone-parent families (%)    |    LONEPARENT  | v_CA16_497|v_CA21_528 |
|5| Infrastructure and built environment  | Inhabitants who are not living in suitable accommodations according to the National Occupancy Standard (NOS) %|CROWDHOME| v_CA16_4861|v_CA21_4262 |
|6| Infrastructure and built environment  | Inhabitants living in private dwellings in need of major repair    |    REPAIRHOME   |v_CA16_4872 | v_CA21_4274|
|7| Infrastructure and built environment  | Inhabitants whose primary mode of transportation is public transit such as bus, subway, ferry   |    PUBTRANSIT   |v_CA16_5801 |v_CA21_7644 |
|8| Infrastructure and built environment  | People whose place of residence was in the same CSD but a different dwelling a year ago     |    MOVERS  |v_CA16_6698| v_CA21_5751|
|9| Infrastructure and built environment  | The population of renters (%)    |    RENTER  | v_CA16_4838| v_CA21_4239|
|10| Infrastructure and built environment  | Apartments in buildings with five or more storeys (%)     |   APT5STORY  |v_CA16_410 |v_CA21_440 |
|11| Infrastructure and built environment  | Dwellings that had been built before 1960    |    BUILT1960   |v_CA16_4863 |v_CA21_4264 |
|12| Economic | Recipient of government transfers     |    GOVTRANSFER   |v_CA16_2222 |v_CA21_581 |
|13| Economic | Annual family income less than $30,000 (after tax) %     |    LOWINCOME   | v_CA16_2570|v_CA21_1085 |
|14| Economic | Annual family income less than $30,000 (after tax) for senior people (65 or above)     |    LOWINCSENIOR   |v_CA16_2570 | v_CA21_1097|
|15| Economic | Households with a shelter-cost-to-income ratio of over 30%     |    SHELTCOSTR  | v_CA16_4888| v_CA21_4290|
|16| Economic | Unemployed people with age 15 or above (%)     |    UNEMPLOYED  |v_CA16_5606 |v_CA21_6501 |
|17| Economic | Median total income of households in 2015 ($)     |   MEDHHINC   |v_CA16_2397 | v_CA21_906|
|18| Economic | The median value of dwellings ($)    |    MEDHOMVAL |v_CA16_4895 | v_CA21_4311|
|19| Economic | People (aged 15 or above) that are not in the labour force (%)    |    NILF  |v_CA16_5609 | v_CA21_6504|
|20| Demographic  | Population density     |    POPDENSITY   | v_CA16_406|v_CA21_6 |
|21| Demographic  | Inhabitants aged 0 to 15 (%)   |    BELOW15  |v_CA16_385 |v_CA21_11 |
|22| Demographic  | Inhabitants aged 65 or older (%)     |    SENIOR   |v_CA16_391 |v_CA21_251 |
|23| Demographic  | Female population (%)     |    FEMALE   | v_CA16_384|v_CA21_10 |
|24| Cultural  | People who recently immigrated (%)    |    RECENTIMMIGNT   |v_CA16_3432 |v_CA21_4431 |
|25| Cultural  | Inhabitants with first-nation status (%)     |    FIRSTGEN   |v_CA16_3822 | v_CA21_4821|
|26| Cultural  | Inhabitants, other than Aboriginal peoples, who are non-Caucasian in race or non-white in colour    |    VISMIN   | v_CA16_3990 |v_CA21_4908 |
|27| Cultural  | Aboriginal Peoples (%)     |    ABORIGINAL   | v_CA16_3855| - |

### Extracting the boundaries:

The first step is to get the Census boundaries that we want to get the data in this case we choose Diseemination Area (DA), Census Division (CD), Census Metropolitan Area (CMA),
Census Sub Division (CSD) and provinces (PR).

The flow work will consist in create an *Cache*, *Input* and *Output* folder. So, we will donwload the boundaries files from [Census 2016](https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2016-eng.cfm) and [Census 2021](https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21)
and create an folder for the Area of Interest example `input\boundaries_21DA\` and we extract the donwload content in there, so we will get an url as `input\boundaries_21DA\lda_000b21a_e\lda_000b21a_e.shp`.
Once set-up this flow-work is moment to start to query to CanCensus RPackage.

The next example can be find in the *.R* files, and its replicate for each scale mentioned above (DA,CD,CMA,CT,PR) for the Census 2021. For this replication in the code, we started to query through Dissemination Area scale, and the dataset response worked as input to define the *regions* parameter for the queries in the another scales.

#### 1. Opening the boundaries. 

```
library(sf)
library(cancensus)
library(tidyverse)

set_cancensus_cache_path(paste0(here::here(),"\\cache"))                                                 # Set-up the  cache
boundaries21<-st_read(paste0(here::here(),"\\input\\boundaries_21DA\\lda_000b21a_e\\lda_000b21a_e.shp")) # Reading the boundary file

```

#### 2. Set-up the variables of interest with its abbreviation form.

```
query<-paste0("v_CA21_",
              as.character(c(553,1156,5820,528,4262,4274,7644,5751,4239,440,4264,581,1085,1097,4290,
              6501,906,4311,6504,6,11,251,4431,4821,4908,10))
              )

# It is important to keep the same order between the variable code and its abbreviation.

nombres <-c("ONEPERSONHH","NOLANG","NODEGREE","LONEPARENT","CROWDHOME","REPAIRHOME","PUBTRANSIT","MOVERS","RENTER",
              "APT5STORY","BUILT1960","GOVTRANSFER","LOWINCOME","LOWINCSENIOR","SHLTCOSTR","UNEMPLOYED","MEDHHINC",
              "MEDHOMVAL","NILF","POPDENSITY","BELOW15","SENIOR","RECENTIMMIGRANT","FIRSTGENERATION","VISMIN_NIE","FEMALE")
             
```


#### 3. Querying to CanCensus
The Query will be divided in two parts, in the region parameter will be necessary to change the extension according the boundaring file
```
query21da<-get_census(dataset='CA21',                                     # Choose the census year, for example for 2016 will be CA16
                       regions= list(DA=boundaries21$DAUID[1:(57932/2)]), # In 2016, for example, will be 56589 instead 57932
                       vector=query,                                      # The variables to query
                       level="DA",                                        # The scale to query
                       use_cache = F)
                       
query21da_2<-get_census(dataset='CA21',                                   # Choose the census year, for example for 2016 will be CA16
                       regions= list(DA=boundaries21$DAUID[1:(57932/2)]), # In 2016, for example, will be 56589 instead 57932
                       vector=query,                                      # The variables to query
                       level="DA",                                        # The scale to query
                       use_cache = F)
                        
#Joining the datasets
query21da<-rbind(query21da,query21da_2)

rm(query21da_2) #removing the second query no save memory
```

#### 4. Changing the name to the columns

```
code_abvt<-data.frame(code=query,abbrvtn=nombres)           # We create an code abbreviation


#We create a function to repeat the same process with all the datasets:

col_format<-function(x){
  code_abvt
  target<-tail(sub(":.*", "", colnames(x)),n=26)            # We are defining the last 26 columns, they are the variable of interest
  code_rplcmnt<-code_abvt[match(target,code_abvt$code),]    # We said that our code_abvt should match in order with our dataset query
  print(code_rplcmnt$code==target)                          # Say us if  our code_abvt has the same order that our dataset
  code_rplcmnt$code                                         # This keep this data in this section of the function
  a<-ncol(x)-26                                             # We try to capture how many columns before our variable of interest there are
  b<-a+48                                                   # We sum it to this so this is the extension of our dataset
  colnames(x)[a+1:b]<-code_rplcmnt$abbrvtn                  # We start to replace it 
  x                                                         # This keep this data in this section of the function
  return(x)                                                 # Return the results
}


query21da_form<-col_format(query21da)                       # Aplying the function to our dataset query

```


#### 5. Saving the results 
```
write.csv(query21da,"output/rawdata/csv/query21cd.csv")                 # We save the results in csv format
writexl::write_xlsx(query21da,"output/rawdata/xlsx/query21da.xlsx")     # We save the results in excel format
```
