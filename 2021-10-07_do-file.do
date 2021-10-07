* erstellt von VORNAME NACHNAME
* zuletzt bearbeitet am 06.08.2019

version 15.1    // Stata-Version prüfen

pause off      // "pause" ausstellen
set more off    // "more" ausstellen

cap log close    // logfile schließen, falls noch eines geöffnet ist

cd "C:\Users\cfriedrich\stataprojekt\log"  // in das das log-Unterverzeichnis des Projektordners wechseln
log using "log_`: di %tdCY-N-D daily("$S_DATE", "DMY")'", append    // neues logfile mit aktuellem Datum im Dateinamen starten, an altes anhängen

cd "C:\Users\cfriedrich\stataprojekt\data"  // in das data-Unterverzeichnis des Projektordners wechseln

use data1, clear    // den Datensatz "data1.dta" öffnen
 
 
generate var1 = 1

replace var1 = 2

tab var1

summarize income

generate incover20k = .
replace incover20k = 1 if income > 20000
replace incover20k = 0 if income <= 20000

tab incover20k

generate geschlecht = sex // Kopie von sex erstellen -> "geschlecht"
replace geschlecht = 0 if sex == 2 // geschlecht auf 0 setzen, wenn weiblich

tab sex geschlecht // Umkodierung überprüfen

gen pchhinc = hhinc / hhsize
list hhinc hhsize pchhinc in 1/10

gen rawinc = hhinc - rent

gen hhincUSD = hhinc * 1.18

gen hhincUSDr = round(hhincUSD)

list hhinc rent rawinc hhincUSD hhincUSDr in 1/10

list rawinc in 1/10 if rawinc > 10000 & rawinc != . // an missings denken

gen loginc = log(income)
hist income
hist loginc
graph box income
graph box loginc

tab income if income == 0
tab income if missing(income), mis
replace income = .c if income == 0
tab income if missing(income), mis

recode ybirth (min/1991 = 0) (1992/max = 1), gen(minder3)


*******************************
** UEBUNG 1: DATENMANAGEMENT  **
 ******************************* 

****
* 1.
* Legen Sie ein Do-File mit typischen Header-Befehlen an, die am Beginn eines 
* jeden Do-Files stehen sollten und speichern Sie sich dieses in ihrem Do-File
* Ordner ab.
*


**** 
* 2.
* Laden Sie den Beispieldatensatz data1.dta.
*


**** 
* 3.
* Kodieren Sie den Wert "other" der Variable "edu" als missing value
*
tab edu
tab edu, nolab

fre edu

replace edu = . if edu == 5

generate other = edu
replace other = . if edu == 5

recode edu (5 = .c), gen(edu2)
tab edu edu2, mis


****
* 4.
* Erstellen Sie folgende Variablen:
* - Alter der Befragten
* - Wohnfläche in Quadratmetern
*
generate alter = 2009 - ybirth
list ybirth alter in 1/10
label variable alter "Alter der Befragten"

generate wohnflaeche = size * 0.0929
list size wohnflaeche in 1/10
label variable wohnflaeche "Wohnfläche in qm"

* generate wohnflaeche = size / 10.76



****
* 5.
* Bilden Sie eine neue Variable, die das Alter der Befragten in folgende Altersgruppen
* zusammenfasst:
* 1 = 1909-1941
* 2 = 1942-1955
* 3 = 1956-1965
* 4 = 1966-1977
* 5 = 1978-1992
*

generate altersgruppe = .
replace altersgruppe = 1 if ybirth >= 1909 & ybirth <= 1941
replace altersgruppe = 2 if ybirth >= 1942 & ybirth <= 1955
replace altersgruppe = 3 if ybirth >= 1956 & ybirth <= 1965
replace altersgruppe = 4 if ybirth >= 1966 & ybirth <= 1977
replace altersgruppe = 5 if ybirth >= 1978 & ybirth <= 1992

label define altersgruppe_lb ///
    1 "1909-1941" ///
	2 "1942-1955" ///
	3 "1956-1965" ///
	4 "1966-1977" ///
	5 "1978-1992"
label values altersgruppe altersgruppe_lb

tab altersgruppe, mis
	
****
* 6. 
* Erstellen Sie einen Mittelwertindex zur Messung der allgemeinen Besorgnis aus den
* Variablen wor01-wor12.
*




********************
*
* this is
* where the
* magic
* happens
* (supposedly)
*
********************


log close    // das logfile schließen

exit    // do-file beenden
