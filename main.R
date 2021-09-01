source("random_list.R")
source("tokens.R")

library("readxl")

# Read all study numbers assigned in every ICARIA REDCap project together with 
# the letter of the bottle used to administer the investigational product
vars <- c('record_id', 'study_number', 'int_azi', 'int_random_letter')
study.numbers <- data.frame()
for (project in names(kRedcapTokens)) {
  print(paste("Reading study numbers from", project)) 
  data <- ReadData(kRedcapAPIURL, kRedcapTokens[[project]], variables = vars)
  data <- data[which(data$int_azi == '1'), ]
  data$hf <- project
  
  study.numbers <- rbind(study.numbers, data)
}

# Order data frame by study number to be aligned with random list
vars <- c('hf', 'record_id', 'study_number', 'int_random_letter')
study.numbers <- study.numbers[order(study.numbers$study_number), vars]

# Read the ICARIA random list
random.list <- read_excel("icaria_randomlist.xlsx")

# Join the treatment letter from the random list to the study numbers data frame
study.numbers <- merge(
  x    = study.numbers, 
  y    = random.list, 
  by.x = "study_number", 
  by.y = "studynum"
)

# Add a new column that indicates whether the administered solution was the 
# adequate according to the ICARIA randomization list
study.numbers$correct.treat <- 
  study.numbers$int_random_letter == study.numbers$treatment