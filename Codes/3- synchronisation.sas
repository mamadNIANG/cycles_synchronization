libname in "C:\Users\dionc\Desktop\Projet_SAS\Donnees";
libname on "C:\Users\dionc\Desktop\Projet_SAS\Donnees\Table_statistique_synchro";

/********************************************************************************************************************
                                 I -   PREPARATION DE NOTRE ECHANTILLON
*********************************************************************************************************************/
/* option 1 -> cycle lissées avec proc ucm*/
data cycle_m3; set in.ucm_forecasts_m3;  keep date s_cycle f_cycle; rename s_cycle=s_cycle_m3 f_cycle=f_cycle_m3; run;
data cycle_m2; set in.ucm_forecasts_m2;  keep date s_cycle f_cycle; rename s_cycle=s_cycle_m2 f_cycle=f_cycle_m2; run;
data cycle_cz; set in.ucm_forecasts_cz;  keep date s_cycle f_cycle; rename s_cycle=s_cycle_cz f_cycle=f_cycle_cz; run;
data cycle_credit; set in.ucm_forecasts_credit;  keep date s_cycle f_cycle; rename s_cycle=s_cycle_credit f_cycle=f_cycle_credit; run;

/* option 2 -> cycle lissées avec proc expand (filtre  hodrick-prescott) */
data cycle_m3; set in.expand_forecasts_m3;  keep date m3_hpc ; rename m3_hpc=s_cycle_m3 ; run;
data cycle_m2; set in.expand_forecasts_m2;  keep date m2_hpc ; rename m2_hpc=s_cycle_m2 ; run;
data cycle_cz; set in.expand_forecasts_cz;  keep date cz_hpc ; rename cz_hpc=s_cycle_cz ; run;
data cycle_credit; set in.expand_forecasts_credit;  keep date credit_conso_resid_million_hpc ; rename credit_conso_resid_million_hpc=s_cycle_credit ; run;


data all_cycle; merge cycle_credit(in=obs1) cycle_cz(in=obs2) cycle_m2(in=obs3) cycle_m3(in=obs4);
if obs1=1 and obs2=1;
by date;
run;

data in.all_cycle; set all_cycle; Obs=_n_;run;



/******************************************************************************************************************************************
                               II-  CROSS-CORRELLATION ANALYSIS (credit_conso ~  m3) 
*******************************************************************************************************************************************/
ods rtf file="C:\Users\dionc\Desktop\Projet_SAS\Documents\graph_correlations.doc";

proc timeseries data=in.all_cycle crossplot=all outcrosscorr=on.HP_outcrosscorr_credit_m3;
id date interval=month;
crosscorr lag n ccov ccf ccfstd CCFPROB/* /nlags=4 */;
var s_cycle_credit /*s_cycle_credit*/;
crossvar s_cycle_m3;
run;



/******************************************************************************************************************************************
                                 CROSS-CORRELLATION ANALYSIS (credit_conso ~  cz) 
*******************************************************************************************************************************************/

proc timeseries data=in.all_cycle crossplot=all outcrosscorr=on.HP_outcrosscorr_credit_cz;
id date interval=month;
crosscorr lag n ccov ccf ccfstd CCFPROB/* /nlags=4 */;
var s_cycle_credit /*s_cycle_credit*/;
crossvar s_cycle_cz;
run;



/******************************************************************************************************************************************
                                 CROSS-CORRELLATION ANALYSIS (m3 ~  cz) 
*******************************************************************************************************************************************/

proc timeseries data=in.all_cycle crossplot=all outcrosscorr=on.HP_outcrosscorr_m3_cz;
id date interval=month;
crosscorr lag n ccov ccf ccfstd CCFPROB/* /nlags=4 */;
var s_cycle_m3 /*s_cycle_credit*/;
crossvar s_cycle_cz;
run;

ods rtf close;
ods html;



/*******************************************************************************************************************************************************************************************************************************/




/********************************************************************************************************************************************************
                           III-  EXTRACTION DES POINTS DE RUPTURES ET DATES ASSOCIES DES CYCLES LISSEES
                 ------>         PROGRAMME R - "C:\Users\dionc\Desktop\Projet_SAS\Codes\BCDAting.R" ( doit être exécuter)
*********************************************************************************************************************************************************/
/*RECUPERATION TABLE SORTIE PROGRAMME R*/
DATA  in.all_phase ;
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
/**************************************/

data all_phase; set in.all_phase;run;
data all_cycle; set in.all_cycle;run;

data all_cycle_plus;merge all_cycle all_phase;
by obs;
run;

data all_cycle_plus; set all_cycle_plus;
if ind_cz=1 then etat_cz="EXPANSION"; else etat_cz="RECESSION";
if ind_credit_conso=1 then etat_credit_conso="EXPANSION"; else etat_credit_conso="RECESSION";
if ind_m2=1 then etat_m2="EXPANSION"; else etat_m2="RECESSION";
if ind_m3=1 then etat_m3="EXPANSION"; else etat_m3="RECESSION";
run;

proc sql;
create table in.all_cycle_plus as select obs,
date, 
s_cycle_credit,
s_cycle_cz,
s_cycle_m2,
s_cycle_m3,
ind_credit_conso,
ind_cz,
ind_m2,
ind_m3,
etat_credit_conso,
etat_cz,
etat_m2,
etat_m3 
from all_cycle_plus;
quit;




/********************************************************************************************************************************************************
                                         IV - CALCUL-INDICE DE CONCORDANCE
*********************************************************************************************************************************************************/
data temp1;set in.all_cycle_plus;run;

data temp1;set temp1;
if ind_cz=-1 then do; ind_cz=0;end;
if ind_m3=-1 then do; ind_m3=0;end;
if ind_credit_conso=-1 then do; ind_credit_conso=0;end;
run;

data temp1;set temp1;
cz_m3=(ind_cz*ind_m3)+(1-ind_cz)*(1-ind_m3);
cz_creditconso=(ind_cz*ind_credit_conso)+(1-ind_cz)*(1-ind_credit_conso);
m3_creditconso=(ind_m3*ind_credit_conso)+(1-ind_m3)*(1-ind_credit_conso);
run;

proc means data=temp1 mean; 
var  m3_creditconso cz_m3  cz_creditconso;
output out=indice_concordance;
run;

data indice_concordance; set indice_concordance;
if _stat_="MEAN";
drop _stat_ _freq_ _type_;
run;

proc transpose data=indice_concordance out=indice_concordance; run;

data indice_concordance; set indice_concordance;
rename col1=Indice_concordance;
run;

/* Significativité des indices*/
data temp1; set temp1;
cle=1;run;

proc means data=temp1 std ;
var ind_cz ind_m3 ind_credit_conso;
output out= ecart_type
std = std_cz std_m3 std_credit_conso;
run;

data ecart_type; set ecart_type;
cle=1;
run;

data regression; merge temp1(in=obs1) ecart_type;
by cle ;
if obs1=1;
drop cle;
run;

data regression; set regression;
reg_cz=ind_cz/std_cz;
reg_m3=ind_m3/std_m3;
reg_credit_conso=ind_credit_conso/std_credit_conso;
run;

/* cz_m3 significativité*/
proc reg data=regression tableout outest=parm1 noprint;
model reg_m3= reg_cz;
run;
quit;

data parm1; set parm1;
if _type_="PVALUE" or _type_="PARMS";
keep _type_  reg_cz;
rename reg_cz=cz_m3;
run;

proc transpose data=parm1 out=parm1; run;
data parm1; set parm1; 
rename col1=Rho col2=pvalue;
run;

/* cz_credit_conso*/
proc reg data=regression tableout outest=parm2 noprint;
model reg_credit_conso= reg_cz;
run;
quit;

data parm2; set parm2;
if _type_="PVALUE" or _type_="PARMS";
keep _type_  reg_cz;
rename reg_cz=cz_creditconso;
run;

proc transpose data=parm2 out=parm2; run;
data parm2; set parm2; 
rename col1=Rho col2=pvalue;
run;

/* m3 - credit_conso*/
proc reg data=regression tableout outest=parm3 noprint;
model reg_credit_conso= reg_m3;
run;
quit;

data parm3; set parm3;
if _type_="PVALUE" or _type_="PARMS";
keep _type_  reg_m3;
rename reg_m3=m3_creditconso;
run;

proc transpose data=parm3 out=parm3; run;
data parm3; set parm3; 
rename col1=Rho col2=pvalue;
run;

data parms; length _name_ $20.;set parm1 parm2 parm3; run;

proc sort data=parms; by _name_;run;
proc sort data=indice_concordance; by _name_;run;

data indice_signi; merge indice_concordance parms; 
by _name_; 
run;

data on.HP_concordance; set indice_signi;run;
proc print data=on.HP_concordance;run;
