libname in"C:\Users\dionc\Desktop\Projet_SAS\Donnees";


/*****************************************************************************************************
                                         TRANSFORMATION LOGARITHME
******************************************************************************************************/
data in.donnees_ind_prod; set in.donnees_ind_prod;
lg_cz=log(cz);
run;

data in.donnees_credit; set in.donnees_credit;
lg_credit_conso_resid_million=log(credit_conso_resid_million);
lg_total_credit_resid_million=log(total_credit_resid_million);
run;

data in.donnees_m3_m2; set in.donnees_m3_m2;
lg_m2=log(m2_fr_million);
lg_m3=log(m3_fr_million);
run;




/**************************************************/
            /*CHOIX DU LAMBDA  H-P*/
%let lambda=14400 ;
/**************************************************/


/*********************************************************************************************************************
                                             CYCLE DU CREDIT
**********************************************************************************************************************/

proc expand data=in.donnees_credit out=in.EXPAND_FORECASTS_credit   method=none;
id date;
Convert lg_credit_conso_resid_million=credit_conso_resid_million_hpt/transformout=(hp_t &lambda.);
Convert lg_credit_conso_resid_million=credit_conso_resid_million_hpc/transformout=(hp_c &lambda.);
run;

/*********************************************************************************************************************************/

proc expand data=in.donnees_credit out=in.EXPAND_FORECASTS_credit_total    method=none;
id date;
Convert lg_total_credit_resid_million=total_credit_resid_million_hpt/transformout=(hp_t &lambda.);
Convert lg_total_credit_resid_million=total_credit_resid_million_hpc/transformout=(hp_c &lambda.);
run;




/*********************************************************************************************************************
                                     CYCLE DE LA MONNAIE
**********************************************************************************************************************/

proc expand data=in.donnees_m3_m2 out=in.EXPAND_FORECASTS_m3    method=none;
id date;
Convert lg_m3=m3_hpt/transformout=(hp_t &lambda.);
Convert lg_m3=m3_hpc/transformout=(hp_c &lambda.);
run;

/****************************************************************************************************************************/

proc expand data=in.donnees_m3_m2 out=in.EXPAND_FORECASTS_m2    method=none;
id date;
Convert lg_m2=m2_hpt/transformout=(hp_t &lambda.);
Convert lg_m2=m2_hpc/transformout=(hp_c &lambda.);
run;




/*********************************************************************************************************************
                                             CYCLE DE L'ACTIVITE ECONOMIQUE
**********************************************************************************************************************/

proc expand data=in.donnees_ind_prod out=in.EXPAND_FORECASTS_cz    method=none;
id date;
Convert lg_cz=cz_hpt/transformout=(hp_t &lambda.);
Convert lg_cz=cz_hpc/transformout=(hp_c &lambda.);
run;

/* RECUPERATION hp_c hp_t    */




/*********************************************************************************************************************
                                             VISUALISATION DES COMPOSANTES CYCLIQUES (HODRICK PRESCOTT )
**********************************************************************************************************************/

ods rtf file="C:\Users\dionc\Desktop\Projet_SAS\Documents\Graphiques-Cycles-HP-lambda14400.doc";
symbol1 i=join  color=green;
proc gplot data=in.EXPAND_FORECASTS_cz;
plot cz_hpc*date;
title "Cycle - Indice de production industrielle (HP)";
run;
quit;

proc gplot data=in.EXPAND_FORECASTS_m2;
plot m2_hpc*date;
title "Cycle - M2 (HP)";
run;
quit;
 
proc gplot data=in.EXPAND_FORECASTS_m3;
plot m3_hpc*date;
title "Cycle - M3 (HP)";
run;
quit;

proc gplot data=in.EXPAND_FORECASTS_credit;
plot credit_conso_resid_million_hpc*date;
title "Cycle - crédit à la consommation (HP)";
run;
quit;
ods rtf close;
ods html;




