**************//// Covid 19-HK border restriction extension-SCM ////*************
// import data //
use "/Users/yan/Desktop/COVID_SCM/封关&隔离/three phases/phase3/full data_phase 3.dta", clear


//summary statistics //
drop if Date<20200125

asdoc sum Total_confirmed New_Confirmed total_14movavg totalper_14movavg inflow outflow GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI



//prepare data//
destring New_Confirmed Total_confirmed AQI TEM RHU1 WINms MoveIn_Index MoveOut_Index 年平均人口万人 行政区域土地面积平方公里TotalLandAreaof 本年度国内生产总值万元 人均国内生产总值元 医院卫生院数个 医院卫生院床位数张 医生数人, replace force

gen GDPmillion=本年度国内生产总值万元/100
gen populationdensity=(年平均人口万人*10000)/行政区域土地面积平方公里TotalLandAreaof
gen 每万人确诊数量=Total_confirmed/年平均人口万人
gen 每万人医院床位数=医院卫生院床位数张/年平均人口万人
gen 每万人医生数=医生数人/年平均人口万人

gen inflow=MoveIn_Index*71121
gen outflow=MoveOut_Index*71121

drop if 年平均人口万人==.


rename 人均国内生产总值元 GDPpercapita
rename populationdensity popdensity


//select sample period//

drop if Date<20200423

log close
cd "/Users/yan/Desktop/COVID_SCM/封关&隔离/three phases/phase3"
log using panelC.log, append




//deal with missing data: replace with average//

sum GDPmillion GDPpercapita popdensity
replace GDPmillion=199396.3  if GDPmillion==.
replace GDPpercapita=76494.7 if GDPpercapita==.
replace popdensity=871.5959 if popdensity==.

sum 每万人医院床位数 每万人医生数
replace 每万人医院床位数=79.26865  if 每万人医院床位数==.
replace 每万人医生数=39.66513 if 每万人医生数==.





////////
sum AQI
replace AQI=53.59991 if  AQI==.
tab Regin_ID if AQI==.
drop if Regin_ID==154





****************//run SCM//******************

//set up time-serie//
gen ndate=string(Date, "%12.0f")
gen date=date(ndate, "YMD")
format date %td


xtset Regin_ID date


*1. Outcome variable: total cases*
synth Total_confirmed total_14movavg totalper_14movavg GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(22042) figure nested keep(panelC_total_0106)


*2. Outcome variable: daily new cases*
synth New_Confirmed total_14movavg totalper_14movavg GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(22042) figure nested keep(panelC_new_0106)






gen effect= _Y_treated - _Y_synthetic

label variable _time "date"

line effect _time, xline(20200507,lp(dash)) yline(0,lp(dash))




