libname in"C:\Users\dionc\Desktop\Projet_SAS\Donnees";



/********************************************************************************************************************
                                  REPRODUCTION ALGORIHTM DE BRY ET BOCSHAN 
*********************************************************************************************************************/


%macro bry_broschan(data=,obs=);
data temp1; set &data.;
keep date s_cycle;
run;

proc sort data=temp1;by date;run;
proc sort data=temp1 out=temp2; by descending date;run;

data temp2; set temp2;
sup5_cycle=lag5(s_cycle);
sup_cycle=lag(s_cycle);
run; 

data temp1; set temp1;
lag5_cycle=lag5(s_cycle);
lag_cycle=lag(s_cycle);
run;

proc sort data=temp1; by date;run;
proc sort data=temp2; by date;run;
data temp3; merge temp1 temp2;
by date;
run;

data temp3;length statut $10.; set temp3;
if (s_cycle<lag5_cycle) and  (s_cycle<sup5_cycle)  then Statut="CREUX";
if (s_cycle>lag5_cycle) and  (s_cycle>sup5_cycle) then Statut="PICS";
run;

data temp3; length statut_corr $10.; set temp3;
if Statut="CREUX" and (sup_cycle>s_cycle and lag_cycle>s_cycle) then statut_corr="CREUX";
if Statut="PICS" and (s_cycle>sup_cycle and s_cycle>lag_cycle) then statut_corr="PICS";
run;

%LET x=%eval(&obs.-6); 
%put &x.;
data temp3; set temp3;
if _n_<=6 then do statut_corr="";end;
if _n_>=&x. then do statut_corr="";end;
run;

data final; set temp3;
if statut_corr="PICS" or statut_corr="CREUX";
keep statut_corr date s_cycle;
rename statut_corr=statut;
run;

/**/
%do i=1 %to 100;
proc sort data=final; by date;run;
proc sort data=final out=fin2; by descending date; run;

data final; set final; 
lag_cycle=lag(s_cycle);
lag_statut=lag(statut);
run; 

data fin2; set fin2; 
sup_statut=lag(statut);
sup_cycle=lag(s_cycle);
sup_date=lag(date);
run; 

proc sort data=final; by date;run;
proc sort data=fin2; by date; run;
data final1; merge final fin2;
by date;
run;

data final; set final1;
if sup_statut="PICS" and statut="PICS" and s_cycle<sup_cycle then delete;
if sup_statut="CREUX" and statut="CREUX" and s_cycle>sup_cycle then delete;
if lag_statut="PICS" and statut="PICS" and s_cycle<lag_cycle then delete;
if lag_statut="CREUX" and statut="CREUX" and s_cycle>lag_cycle then delete;
run;

data final; set final;
drop sup_statut sup_cycle sup_date;
run;
%end;

data pics; set final;
if statut="PICS";
rename Date=PEAKS s_cycle=valeurs_pics;
run;
data pics; set pics; obs=_n_; drop lag_statut lag_cycle; run;

data creux; set final;
if statut="CREUX";
rename Date=creux statut=statut1 s_cycle=valeurs_creux date=CREUX; 
run;
data creux; set creux; obs=_n_; drop lag_statut lag_cycle; run;

data info; merge pics creux;
by obs;
duration=abs(peaks-creux);
run;

proc sql;
create table info as select statut, 
peaks,
valeurs_pics,
statut1,
creux,
valeurs_creux,
duration
from info;
quit;

data dates_retournements;set final;run;

/**/
proc sort data=temp1; by date;run;
proc sort data=final;by date;run;
data result_macro; merge temp1 final (keep=date statut);
by date;
run;
%mend bry_broschan;
/*******************************************************************************************************************************************/
/* test*/
%bry_broschan(data=in.ucm_forecasts_cz, obs=365);
%bry_broschan(data=in.ucm_forecasts_credit, obs=311);

/*******************************************************************************************************************************************/





/********************************************************************************************************************************************************
                               EXTRACTION DES POINTS DE RUPTURES ET DATES ASSOCIES DANS LES CYCLES LISSEES
                               (ALGO DOMINIQUE LAYAE)
*********************************************************************************************************************************************************/

LIBNAME store "C:\Users\dionc\Desktop\Projet_SAS\Codes";
OPTIONS MSTORED SASMSTORE=store;

%PAT(DATA=in.UCM_FORECASTS_cz,XX=s_cycle,DATE=date,NFOR=1);
%PAT(DATA=in.UCM_FORECASTS_m3,XX=s_cycle,DATE=date,NFOR=1);
%PAT(DATA=in.UCM_FORECASTS_credit,XX=s_cycle,DATE=date,NFOR=1);
