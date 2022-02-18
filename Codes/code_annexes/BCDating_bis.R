install.packages("BCDating")
install.packages("haven")
install.packages("forecast")


# CZ
library(haven)
series1<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/ucm_forecasts_cz.sas7bdat")
cz<-series1$S_CYCLE

library(forecast)
cz_times_series<-ts(cz, start=c(1990, 1), end=c(2020, 5), frequency=12)

library(BCDating)
dat1 <- BBQ(cz_times_series,minphase = 6, name="Dating CZ")
show(dat1)
plot(dat1)
ind_cz<-dat1@states
phase_cz <- data.frame(series1$Obs,ind_cz)


# m2
library(haven)
series2<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/ucm_forecasts_m2.sas7bdat")
m2<-series2$S_CYCLE

library(forecast)
m2_times_series<-ts(m2, start=c(1980, 1), end=c(2020, 10), frequency=12)

library(BCDating)
dat2 <- BBQ(m2_times_series,minphase = 6, name="Dating m2")
show(dat2)
plot(dat2)
ind_m2<-dat2@states
phase_m2 <- data.frame(series2$Obs,ind_m2)


# credit_conso
library(haven)
series3<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/ucm_forecasts_credit.sas7bdat")
credit_conso<-series3$S_CYCLE

library(forecast)
credit_conso_times_series<-ts(credit_conso, start=c(1993, 5), end=c(2020, 10), frequency=12)

library(BCDating)
dat3 <- BBQ(credit_conso_times_series,minphase = 6, name="Dating credit_conso")
show(dat3)
plot(dat3)
ind_credit_conso<-dat3@states
phase_credit_conso <- data.frame(series3$Obs,ind_credit_conso)

phase_all<-(series1$Obs, )