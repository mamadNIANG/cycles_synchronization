* Written by R;
*  write.foreign(phase_all, "C:/Users/dionc/Desktop/Projet_SAS/Donnees/Phase_cycle.txt",  ;

DATA  rdata ;
INFILE  "C:/Users/dionc/Desktop/Projet_SAS/Donnees/Phase_cycle.txt" 
     DSD 
     LRECL= 19 ;
INPUT
 obs
 ind_cz
 ind_credit_conso
 ind_m2
 ind_m3
;
RUN;
