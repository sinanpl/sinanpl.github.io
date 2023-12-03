library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)

# inspiration: https://public.tableau.com/profile/bo.mccready8742#!/vizhome/TheMostCommonBirthdaysintheUnitedStates/CommonBirthdays
if (!file.exists("data/STATBEL_BIRTHDAYS.xlsx")){
  data_url = "https://statbel.fgov.be/sites/default/files/files/opendata/birthdays/TF_BIRTHDAYS.xlsx"
  download.file(data_url, "data/STATBEL_BIRTHDAYS.xlsx", mode="wb")
}

if (!file.exists("data/STATBEL_BIRTHS.xlsx")){
  data_url = "https://statbel.fgov.be/sites/default/files/files/opendata/bevolking/Geboorte/TF_BIRTHS.xlsx"
  download.file(data_url, "data/STATBEL_BIRTHDAYS.xlsx", mode="wb")
}

# source holidays ----------------------------------------------------

source('scrape_historical_belgian_holidays.R')

# births -------------------------------------------------------------

births = readxl::read_excel('data/STATBEL_BIRTHDAYS.xlsx') %>% 
  dplyr::rename(date = DT_DATE, nbirths = MS_NUM_BIRTHS) %>% 
  dplyr::mutate(
    date = as.Date(date)
  )

conceptions = births %>% 
  mutate(date = date - lubridate::days(x=266)) %>%   # see dailyviz and https://www.betterhealth.vic.gov.au/health/healthyliving/baby-due-date
  dplyr::rename(nconceptions = nbirths)


(
  births_conceptions_be =  births %>% 
  dplyr::full_join(conceptions) %>% 
  dplyr::mutate(
    dd = lubridate::day(date), 
    mm = lubridate::month(date), 
    yy = lubridate::year(date), 
    day_of_year = lubridate::yday(date), 
    weekday = lubridate::wday(date, label = TRUE, week_start = 1)
  ) %>% 
  dplyr::mutate(dplyr::across(c(dd, mm, yy), factor, ordered=TRUE)) %>% 
  dplyr::left_join(holidays) %>% 
  dplyr::arrange(date)
)

sum(births_conceptions_be$nconceptions, na.rm=TRUE)
# [1] 3472601
sum(births_conceptions_be$nbirths, na.rm=TRUE)
# [1] 3472433

sum(births$nbirths)
sum(conceptions$nconceptions)

saveRDS(births_conceptions_be, 'births_conceptions_be.rds')



# birthdays ----------------------------------------------------------


birthdays_base = readxl::read_excel('data/STATBEL_BIRTHDAYS.xlsx') %>% 
  janitor::clean_names() %>% 
  dplyr::filter(
    (day != 1  | !(month %in% c(1,7))) & ## 1/01 and 1/07 are inflated due to registration
    (day != 29 | month != 2)                  ## 29/02 leap year 
  )

holidays = tibble::tribble(
  ~day,~month,~holiday, 
  1,   1,     'Nieuwjaarsdag',
  1,   5,     'Dag van de Arbeid',
  21,  7,     'Nationale feestdag',
  15,  8,     'O.L.V. Hemelvaart',
  1,   11,    'Allerheiligen',
  11,  11,    'Wapenstilstand van 1918',
  25,  12,    'Kerstmis'
)


birthdays_base = birthdays_base %>% 
  left_join(holidays) %>% 
  dplyr::mutate(
    day = factor(day), 
    month=factor(month, labels = month.abb), 
    odds = round(belgium / mean(belgium), 2)
  )
