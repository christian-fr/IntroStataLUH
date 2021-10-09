* erstellt von VORNAME NACHNAME
* zuletzt bearbeitet am 06.08.2019

version 15.1    // Stata-Version prüfen

pause off      // "pause" ausstellen
set more off    // "more" ausstellen

cap log close    // logfile schließen, falls noch eines geöffnet ist

cd "C:\Users\cfriedrich\stataprojekt\log"  // in das das log-Unterverzeichnis des Projektordners wechseln
log using "log_`: di %tdCY-N-D daily("$S_DATE", "DMY")'", append    // neues logfile mit aktuellem Datum im Dateinamen starten, an altes anhängen

cd "C:\Users\cfriedrich\stataprojekt\data"  // in das data-Unterverzeichnis des Projektordners wechseln


use kksoep\zp, clear
tab zp12401, mis // missings (-2,-1) müssen umkodiert werden

gen pp = zp12401 // variable kopieren

tab zp12401 if zp12401 < 1, mis // vorher prüfen, was die IF-Bedigung "einfängt"

replace pp = . if zp12401 < 1 // umkodieren

recode zp12401 ( -2 -1 = . ), generate(pp_r)
tab pp_r, mis


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
** Für Grafiken in den Zeilen unten den Kommentar entfernen
* hist income
* hist loginc
* graph box income
* graph box loginc

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




* Zwischenspiel

* Besorgnis
tab1 wor01-wor12
tab1 wor*

numlabel _all, add
tab1 wor*
* umkodieren: so, dass höhere Werte auch höhere Besorgnis ausdrücken
recode wor01-wor12 (1 = 3) (3 = 1), generate(wor01n wor02n ///
	wor03n wor04n wor05n ///
	wor06n wor07n wor08n ///
	wor09n wor10n wor11n ///
	wor12n)

recode wor01-wor12 (1 = 3) (3 = 1), prefix(new_)

label define wor_lb 1 "[1] nicht besorgt" ///
	2 "[2] mittel" ///
	3 "[3] sehr besorgt"
label values new* wor_lb
tab1 new*

* additiven Index erstellen: Besorgnis
gen worindexA = new_wor01 + new_wor02 + new_wor03 + ///
	new_wor04 + new_wor05 + new_wor06 + new_wor07 + ///
	new_wor08 + new_wor09 + new_wor10 + new_wor11 + ///
	new_wor12
list new* worindexA in 1/20, nolab


cap drop worindexB
egen worindexB = rowtotal(new*)
list new* worindexA worindexB in 1/20, nolab

cap drop worindexC
egen worindexC = rowtotal(new*), missing
list new* worindexA worindexB worindexC in 1/100, nolab

	
****
* 6. 
* Erstellen Sie einen Mittelwertindex zur Messung der allgemeinen Besorgnis aus den
* Variablen new_wor01-new_wor12.
*

cap drop var1
gen var1 = .

cap drop worindexD 
egen worindexD = rowmean(new*) 
list new* worindexA worindexB worindexC worindexD in 1/100, nolab

* Cronbach's Alpha berechnen
* misst die interne Konsistenz des Index
* > .65 gilt als annehmbarer Wert
alpha new_*




* Datensätze mergen / appenden

* Infos über Datensätze
desc using pequiv07kk.dta
desc using kksoep\xpequiv.dta

use pequiv07kk.dta, clear
rename (x11101ll x1110207) (hhnr persnr)

cap drop country
gen country = "USA"

append using kksoep\xpequiv.dta
desc, short

replace country = "DE" if country == ""
* alternativ:
* replace country = "DE" if country != "USA"

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* hist i1111007 if i1111007 > 0 & i1111007 < 10000, by(country)

collapse (mean) i1111007, by(country)


* merge
desc using kksoep\ap
desc using kksoep\rp

use kksoep\ap, clear
merge 1:1 persnr using kksoep\rp
d, simple

keep if _merge == 3

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* graph bar ap6801 rp13501, ascategory


* reshape von wide nach long
use data2w, clear
desc
reshape long mar hhinc whours lsat , i(persnr) j(year)
list persnr year mar hhinc whours in 1/100

reshape wide mar hhinc whours lsat , i(persnr) j(year)


* Deskriptive Statistik

use data1, clear
tab emp

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* graph bar emp
* macht keinen Sinn!

tab emp, gen(emp)

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* graph bar emp1-emp4

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* hist emp, discrete percent

** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* graph dot emp1-emp4, ascategory

tab emp sex, col row
tab emp sex, col 


** den Kommentar bei untenstehenden Zeilen entfernen, um Graphen
** ausgeben zu lassen
*
* graph bar emp1-emp4, over(sex)
* graph bar emp1-emp4, by(sex)
* graph bar emp1-emp4, by(state)
* graph export ..\output\BarEmpState.pdf, replace
* graph export ..\output\BarEmpState.png, replace

****
* bivariater Zusammenhang
tab emp sex,chi2 V





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
