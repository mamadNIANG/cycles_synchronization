libname in"C:\Users\dionc\Desktop\Projet_SAS\Donnees";


/*******************************************************************************
                         MACRO UTILE POUR IMPORTATION DES DONNEES
********************************************************************************/

/*macro qui sert à convertir en numeric des var char fichier csv */
%macro numeric(list, data);
%let liste=&list.;
%let x=%sysfunc(countw(&liste.));
%do i=1 %to &x.;
%let var=%scan(&list.,&i.);
data &data.; set &data.;
&var._num=round(input(&var.,12.),0.01);
run;

data &data.; set &data.;
drop &var.;
run;

data &data.; set &data.;
rename &var._num=&var.;
run;
%end;
%mend numeric;



/*******************************************************************************************
               IMPORTATION INDICE DE PRODUCTION (DONNEES MENSUELLES-INSEE)
*********************************************************************************************/

proc import out=ind_prod 
datafile="C:\Users\dionc\Desktop\Projet_SAS\Donnees\IPI_202005.xls" dbms=xls replace;
getnames=yes;
run;

/*traitement var date*/
data ind_prod; set ind_prod;
date_char=put(date,$6.);
date1=substr(date_char,5,2)||"/01/"||substr(date_char,1,4);
date2=input(date1,MMDDYY10.); 
format date2 MMYYS.;
drop date date_char;
run;

proc sql;
create table donnees_ind_prod as select date2 as date, 
be, cz, c1, c2, c3, c4, c5
from ind_prod;
quit;

%numeric( be cz c1 c2 c3 c4 c5, donnees_ind_prod);

data donnees_ind_prod; set donnees_ind_prod;
label be="INDUSTRIE" cz="Industrie manufacturière" c1="Industries agro-alimentaires" c2="Cokéfaction et raffinage" c3="Fab. de biens d'équipement" c4="Fab. de matériels de transport" c5="Fab. d’autres produits industriels"; 
run;

data in.donnees_ind_prod; set donnees_ind_prod;run;



/*******************************************************************************************
        IMPORTATION AGREGAT M3 COMPOSANTE FRANCAISE (DONNEES MENSUELLES-BANQUE DE FRANCE)
*********************************************************************************************/
proc import out=donnees_m3_m2 
datafile="C:\Users\dionc\Desktop\Projet_SAS\Donnees\BF_donnees_m2m3.xlsx" dbms=xlsx replace;
getnames=yes;
sheet="Donnees";
run;

data donnees_m3_m2; set donnees_m3_m2;
format date MMYYS.;
run;

proc sort data=donnees_m3_m2; by date;run;

data in.donnees_m3_m2; set donnees_m3_m2; run;



/*********************************************************************************************************
      IMPORTATION CREDIT ACCORDEES AUX PARTICULIERS REDISENT (DONNEES MENSUELLES - BANQUE DE FRANCE)
***********************************************************************************************************/
proc import out=donnees_credit 
datafile="C:\Users\dionc\Desktop\Projet_SAS\Donnees\BF_donnees_credit.xlsx" dbms=xlsx replace;
getnames=yes;
sheet="Feuil1";
run;

data donnees_credit; set donnees_credit;
format date MMYYS.;
run;

proc sort data=donnees_credit; by date;run;
data in.donnees_credit; set donnees_credit; run;




/**********************************************************************************************************************************                                 
                                                VISUALISATION DES SERIES                                             
************************************************************************************************************************************/

data donnees_m3_m2; set in.donnees_m3_m2;run;
data donnees_credit; set in.donnees_credit;run;
data donnees_ind_prod; set in.donnees_ind_prod;run;


ods rtf file="C:\Users\dionc\Desktop\Projet_SAS\Documents\Graphiques-series.doc";

symbol1 i=join v=none ;
proc gplot data=donnees_m3_m2;
plot m3_fr_million*date;
title "Graphique - M3";
run;
quit;


proc gplot data=donnees_m3_m2;
plot m2_fr_million*date;
title "Graphique - M2";
run;
quit;


proc gplot data=donnees_credit;
plot credit_conso_resid_million*date;
title "Graphique - Crédit à la consommation (résidents)";
run;
quit;

proc gplot data=donnees_ind_prod;
plot cz*date;
title "Graphique - Indice de production industrielle";
run;
quit;
ods rtf close;
ods html;
