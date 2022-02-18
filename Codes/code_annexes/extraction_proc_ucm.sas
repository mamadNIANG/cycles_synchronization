proc ucm data = in.donnees_credit;
      id date interval = month;
      model lg_credit_conso_resid_million ;
      irregular ;
      level ;
      slope ;
      cycle ;
   run ;
/* Les infos nous suggère qu'on peut un peut plus enrivhir le modèle 
   l'estimation de la variance du niveau nous suggère qu'elle n'est pas significative level variance=0 
   l'estimation de la variance de la pente est significative 
*/


/* Extraction du cycle*/
proc ucm data=in.donnees_credit;
id date interval=month;
model lg_credit_conso_resid_million;
irregular;
level variance=0 noest ;
slope variance=6.94e-5 noest;
cycle plot=(filter smooth);
estimate back=24 plot=(loess panel cusum wn)OUTEST=in.UCM_ESTIMATES_credit;
forecast back=24 lead=5 plot=(forecasts decomp) OUTFOR=in.UCM_FORECASTS_credit ;
run;

dm 'odsresults; clear';
proc ucm data = in.donnees_credit;
      id date interval = month;
      model lg_total_credit_resid_million ;
      irregular ;
      level ;
      slope ;
      cycle ;
   run ;


proc ucm data=in.donnees_credit;
id date interval=month;
model lg_total_credit_resid_million;
irregular plot=(smooth filter);
level variance=0 noest ;
slope variance=6.94e-5 noest;
estimate back=24 plot=(loess panel cusum wn)OUTEST=in.UCM_ESTIMATES_credit_total;
forecast back=24 lead=5 plot=(forecasts decomp) OUTFOR=in.UCM_FORECASTS_credit_total ;
run;



proc ucm data = in.donnees_m3_m2;
      id date interval = month;
      model lg_m3 ;
      irregular ;
      level ;
      slope ;
      cycle ;
   run ;


proc ucm data=in.donnees_m3_m2;
id date interval=month;
model lg_m3;
irregular;
level variance=0 noest ;
slope variance=6.94e-5 noest;
cycle plot=(filter smooth);
estimate back=24 plot=(loess panel cusum wn) OUTEST=in.UCM_ESTIMATES_m3;
forecast back=24 lead=5 plot=(forecasts decomp) OUTFOR=in.UCM_FORECASTS_m3 ;
run;

proc ucm data = in.donnees_m3_m2;
      id date interval = month;
      model lg_m2 ;
      irregular ;
      level ;
      slope ;
      cycle ;
   run ;


proc ucm data=in.donnees_m3_m2;
id date interval=month;
model lg_m2;
irregular;
level variance=0 noest ;
slope variance=6.94e-5 noest;
cycle plot=(filter smooth);
estimate back=24 plot=(loess panel cusum wn) OUTEST=in.UCM_ESTIMATES_m2;
forecast back=24 lead=5 plot=(forecasts decomp) OUTFOR=in.UCM_FORECASTS_m2 ;
run;

proc ucm data = in.donnees_ind_prod;
      id date interval = month;
      model lg_cz ;
      irregular ;
      level ;
      slope ;
      cycle ;
   run ;


proc ucm data=in.donnees_ind_prod;
id date interval=month;
model lg_cz;
level variance=0 noest ;
slope variance=6.94e-5 noest;
cycle plot=(filter smooth);
estimate back=24 plot=(loess panel cusum wn)OUTEST=in.UCM_ESTIMATES_cz;
forecast back=24 lead=5 plot=(forecasts decomp) OUTFOR=in.UCM_FORECASTS_cz ;
run;



/*********************************************************************************************************************
                                             VISUALISATION CYCLE ( METHODE - PROC UCM )
**********************************************************************************************************************/

ods rtf file="C:\Users\dionc\Desktop\Projet_SAS\Documents\Graphiques-Cycles-PROCUCM.doc";
symbol1 i=join  color=red;
proc gplot data=in.UCM_FORECASTS_cz;
plot s_cycle*date;
title "Cycle - Indice de production industrielle";
run;
quit;

proc gplot data=in.UCM_FORECASTS_m2;
plot s_cycle*date;
title "Cycle - M2";
run;
quit;
 
proc gplot data=in.UCM_FORECASTS_m3;
plot s_cycle*date;
title "Cycle - M3";
run;
quit;

proc gplot data=in.UCM_FORECASTS_credit;
plot s_cycle*date;
title "Cycle - Crédit à la consommation";
run;
quit;
ods rtf close;
ods html;
