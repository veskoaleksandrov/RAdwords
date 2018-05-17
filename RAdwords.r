#1. Installation and connection of required packages
setwd("O:/Lulu DWH/Scripts/R Scripts/Authorisation Tokens")

package_list<-c("RAdwords","dplyr","lubridate")
#new_packages<-package_list[!package_list%in%installed.packages()[,"Package"]]
#if (length(new_packages)>0) {
#  install.packages(new_packages)
#}
lapply(package_list,require,character=T)

#2. Declaration of variables
clienid <- "" #Client ID from google console
secret <- "" #Client secret из google console
adwords_profil_id<-c("338-037-4272","334-860-5528","173-708-1574","679-662-0876","964-913-8459")#ID of Google AdWords account

#Time period, in which it is needed to determine the amount of lost revenue
min_date<-as.Date(Sys.Date()-3)
max_date<-as.Date(Sys.Date())

#3. Authentication in the services.
#3.1. Authentication in Google Analytics.
adwords_auth <- doAuth(T)

adwordsData<-NULL
Reportfinal<-NULL
###################Looping on first report (FINAL_URL_REPORT)####################
body <- statement(select=c('Date',
                           'AccountDescriptiveName',
                           'AdGroupId',
                           'AdGroupName',
                           'AdGroupStatus',
                           'AveragePosition',
                           'CampaignId',
                           'CampaignName',
                           'CampaignStatus',
                           'Clicks',
                           'Conversions',
                           'Cost',
                           'Impressions',
                           'EffectiveFinalUrl',
                           'EffectiveTrackingUrlTemplate')
                  
                  ,report="FINAL_URL_REPORT"
                  ,start=min_date
                  ,end=max_date)

#4.2.2. Sending the query to Google AdWords
for (i in 1:length(adwords_profil_id)) {
  print(paste0("Calling AW API for: ", adwords_profil_id[i], "..."))
  report <- getData(clientCustomerId = adwords_profil_id[i],
                    google_auth = adwords_auth,statement = body,
                    transformation = TRUE, changeNames = TRUE,
                    includeZeroImpressions = FALSE, verbose = FALSE)
  
  Reportfinal<-rbind(Reportfinal,report)}
#################################################################################

Reportdist<-NULL
###################Looping on Second report (DESTINATION_URL_REPORT)####################
body <- statement(select=c('Date',
                           'AccountDescriptiveName',
                           'AdGroupId',
                           'AdGroupName',
                           'AdGroupStatus',
                           'AveragePosition',
                           'CampaignId',
                           'CampaignName',
                           'CampaignStatus',
                           'EffectiveDestinationUrl',
                           'IsNegative')
                  
                  ,report="DESTINATION_URL_REPORT"
                  ,start=min_date
                  ,end=max_date)

#4.2.2. Sending the query to Google AdWords
for (i in 1:length(adwords_profil_id)) {
  report1 <- getData(clientCustomerId = adwords_profil_id[i],
                     google_auth = adwords_auth,statement = body,
                     transformation = TRUE, changeNames = TRUE,
                     includeZeroImpressions = FALSE, verbose = FALSE)
  
  Reportdist<-rbind(Reportdist,report1)}
#################################################################################

adwordsData1<-left_join(Reportfinal,Reportdist,
                        by=c("Day"="Day","CampaignID"="CampaignID","Account"="Account"
                             ,"AdgroupID"="AdgroupID")
)


adwordsData1<-adwordsData1[,which(regexpr(".*\\.y",names(adwordsData1),ignore.case = T)==-1)]
names(adwordsData1)<-gsub('[.*\\.x]','',names(adwordsData1))

adwordsData1$Isnegative[is.na(adwordsData1$Isnegative)]<-0
adwordsData1$DestinationURL[is.na(adwordsData1$DestinationURL)]<-""

adwordsData1$Day<-ymd(adwordsData1$Day)
adwordsData1$Clicks<-as.numeric(adwordsData1$Clicks)
adwordsData1$Cost<-as.numeric(adwordsData1$Cost)
adwordsData1$Conversions<-as.numeric(adwordsData1$Conversions)
adwordsData1$Impressions<-as.numeric(adwordsData1$Impressions)
adwordsData1$Position<-as.numeric(adwordsData1$Position)
adwordsData1$CampaignID<-as.character(adwordsData1$CampaignID)
adwordsData1$AdgroupID<-as.character(adwordsData1$AdgroupID)

#names<-c("Day","Account","AdgroupID","Adgroup","Adgroupstate","Position","CampaignID","Campaign",
#         "Campaignstate","Clicks","Conversions","Cost","Impressions","FinalURL","Trackingtemplate",
#         "DestinationURL","Isnegative")
########################################
#reports()
#metrics(report='DESTINATION_URL_REPORT')


write.csv(adwordsData1,"O:/Lulu DWH/External Data Integration/Adwords.csv",row.names = F)


