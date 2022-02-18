install.packages("BCDating")
install.packages("haven")
install.packages("forecast")
install.packages("foreign")

# CZ
library(haven)
series1<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/all_cycle.sas7bdat")
cz<-series1$s_cycle_cz

library(forecast)
cz_times_series<-ts(cz, start=c(1993, 5), end=c(2020, 5), frequency=12)

library(BCDating)
dat1 <- BBQ(cz_times_series,minphase = 6, name="Dating CZ")
show(dat1)
plot(dat1)
ind_cz<-dat1@states
phase_cz <- data.frame(series1$Obs,ind_cz)


# m2
library(haven)
series2<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/all_cycle.sas7bdat")
m2<-series2$s_cycle_m2

library(forecast)
m2_times_series<-ts(m2, start=c(1993, 5), end=c(2020, 5), frequency=12)

library(BCDating)
dat2 <- BBQ(m2_times_series,minphase = 6, name="Dating m2")
show(dat2)
plot(dat2)
ind_m2<-dat2@states
phase_m2 <- data.frame(series2$Obs,ind_m2)


# m3
library(haven)
series3<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/all_cycle.sas7bdat")
m3<-series3$s_cycle_m3

library(forecast)
m3_times_series<-ts(m3, start=c(1993, 5), end=c(2020, 5), frequency=12)

library(BCDating)
dat3 <- BBQ(m3_times_series,minphase = 6, name="Dating m2")
show(dat3)
plot(dat3)
ind_m3<-dat3@states
phase_m3 <- data.frame(series3$Obs,ind_m3)


# credit_conso
library(haven)
series4<-read_sas("C:/Users/dionc/Desktop/Projet_SAS/Donnees/all_cycle.sas7bdat")
credit_conso<-series4$s_cycle_credit

library(forecast)
credit_conso_times_series<-ts(credit_conso, start=c(1993, 5), end=c(2020, 5), frequency=12)

library(BCDating)
dat4 <- BBQ(credit_conso_times_series,minphase = 6, name="Dating credit_conso")
show(dat4)
plot(dat4)
ind_credit_conso<-dat4@states
phase_credit_conso <- data.frame(series4$Obs,ind_credit_conso)

obs<-series1$Obs
phase_all<-data.frame(obs,ind_cz, ind_credit_conso, ind_m2, ind_m3 )

library(foreign)
write.foreign(phase_all,"C:/Users/dionc/Desktop/Projet_SAS/Donnees/Phase_cycle.txt","C:/Users/dionc/Desktop/Projet_SAS/Donnees/Phase_cycle.sas",   package="SAS")


