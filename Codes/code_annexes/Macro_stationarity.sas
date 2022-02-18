
/*********************************************************************************************************************************************************************************************
                                VERIFICATION STATIONNARITE                                             
**********************************************************************************************************************************************************************************************/

data donnees_m3_m2; set in.donnees_m3_m2;run;
data donnees_credit; set in.donnees_credit;run;
data donnees_ind_prod; set in.donnees_ind_prod;run;

%macro stationarity(tab, var);
data tt; set &tab.;run;

data tt; set tt;
delta_&var.=lag(&var.)-&var.;
lg_&var.=lag(&var.);
run; 
proc reg data=tt;
model delta_&var.=lg_&var. /noint;
run;
quit;
%mend stationarity;


ods rtf file = "C:\Users\dionc\Desktop\Projet_SAS\Documents\Stationarity.doc" style=Journal;
%stationarity(donnees_ind_prod, cz);
%stationarity(donnees_credit,credit_conso_resid_million);
%stationarity(donnees_m3_m2, m3_fr_million);
%stationarity(donnees_m3_m2, m2_fr_million);

ods rtf close;
ods html;/*retour affichage classique*/
