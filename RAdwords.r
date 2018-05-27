# Install and load required packages
if (!require("RAdwords")) install.packages("RAdwords")
library(RAdwords)
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

# Define Client ID (available in Google Console)
clientId <- c("")
# Define Client Secret (available in Google Console)
clientSecret <- c("")
# Define Account ID (available in Google Adwords)
accountId <- c("") 

# Define time period of report, i.e. last 3 complete days
min_date <- as.Date(Sys.Date() - 3)
max_date <- as.Date(Sys.Date() - 1)

# Authentication 
setwd("O:/path/to/your/access/tokens")
adwordsAuth <- doAuth(T)

# Loop over account IDs
report <- NULL
for (a in 1:length(accountId)) {
  print(paste0("Calling AW API for account ", accountId[a], "..."))
  # Download FINAL_URL_REPORT
  report <- rbind.fill(report, 
                       getData(clientCustomerId = accountId[a],
                               google_auth = adwordsAuth, 
                               statement = statement(select = c('AccountDescriptiveName',
                                                                'AdGroupId',
                                                                'AdGroupName',
                                                                'AdGroupStatus',
                                                                'CampaignId',
                                                                'CampaignName',
                                                                'CampaignStatus',
                                                                'EffectiveFinalUrl',
                                                                'EffectiveTrackingUrlTemplate',
                                                                'Date',
                                                                'Impressions',
                                                                'Clicks',
                                                                'Cost',
                                                                'Conversions', 
                                                                'AveragePosition'), 
                                                     report = "FINAL_URL_REPORT", 
                                                     start = min_date, 
                                                     end = max_date),
                               transformation = TRUE, 
                               changeNames = TRUE,
                               includeZeroImpressions = FALSE, 
                               verbose = FALSE))
  
  # Download DESTINATION_URL_REPORT
  report <- rbind.fill(report, 
                       getData(clientCustomerId = accountId[a],
                               google_auth = adwordsAuth, 
                               statement = statement(select=c('AccountDescriptiveName',
                                                              'AdGroupId',
                                                              'AdGroupName',
                                                              'AdGroupStatus',
                                                              'CampaignId',
                                                              'CampaignName',
                                                              'CampaignStatus',
                                                              'EffectiveDestinationUrl',
                                                              'Date',
                                                              'Impressions',
                                                              'Clicks',
                                                              'Cost', 
                                                              'Conversions', 
                                                              'AveragePosition'), 
                                                     report = "DESTINATION_URL_REPORT", 
                                                     start = min_date, 
                                                     end = max_date), 
                               transformation = TRUE, 
                               changeNames = TRUE, 
                               includeZeroImpressions = FALSE, 
                               verbose = FALSE))
}

# Store reports in CSV file
write.csv(x = report,
          file = "O:/path/to/your/csv/file/adwords.csv", 
          row.names = FALSE)