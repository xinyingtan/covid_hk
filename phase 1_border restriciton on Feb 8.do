**************//// Covid 19-HK border restriction-SCM ////*************
//install SCM package//
ssc install synth, replace

//import data//
use "/Users/yan/Desktop/COVID_SCM/封关&隔离/three phases/phase1/full data_phase1.dta", clear


//prepare data//
destring New_Confirmed Total_confirmed AQI TEM RHU1 WINms MoveIn_Index MoveOut_Index 年平均人口万人 行政区域土地面积平方公里TotalLandAreaof 本年度国内生产总值万元 人均国内生产总值元 医院卫生院数个 医院卫生院床位数张 医生数人, replace force

gen GDPmillion=本年度国内生产总值万元/100
gen popdensity=(年平均人口万人*10000)/行政区域土地面积平方公里TotalLandAreaof
gen 每万人确诊数量=Total_confirmed/年平均人口万人
gen 每万人医院床位数=医院卫生院床位数张/年平均人口万人
gen 每万人医生数=医生数人/年平均人口万人

gen inflow=MoveIn_Index*71121
gen outflow=MoveOut_Index*71121

drop if 年平均人口万人==.
drop if popdensity==.


//setup time serie//
gen ndate=string(Date, "%12.0f")
gen date=date(ndate, "YMD")
format date %td
gen nndate=date(ndate, "YMD")
//define panel data//
xtset Regin_ID date

//create 14-day moving agerages//
tssmooth ma total_14movavg = Total_confirmed, window(14)
tssmooth ma totalper_14movavg = 每万人确诊数量, window(14)
tssmooth ma new_14movavg = New_Confirmed, window(14)


//select sample period//
drop if Date<20200125
drop if Date>20200306

//replace missing AQI with average value//
sum AQI
replace AQI=64.11156  if  AQI==.

//drop city missing weather data//
drop if Regin_ID==154

****************////Model 1: drop Hubei only////****************
cd "/Users/yan/Desktop/COVID_SCM/封关&隔离/three phases/phase1"
log using panel_A_20220106.log, replace

drop if Prov_EN=="Hubei"


///////////explore data//////////
//draw graphs_HK//
line New_Confirmed date if Regin_ID==302 
line Total_confirmed date if Regin_ID==302 

//draw graphs_other cities//
//setup time serie//
gen ndate=string(Date, "%12.0f")
gen date=date(ndate, "YMD")
format date %td
gen nndate=date(ndate, "YMD")
//define panel data//
xtset Regin_ID date

xtgraph New_Confirmed if Regin_ID!=302,av(mean)
xtgraph Total_confirmed if Regin_ID!=302,av(mean)

line inflow date if Regin_ID==302 
xtgraph inflow if Regin_ID!=302,av(mean)

line outflow date if Regin_ID==302 
xtgraph outflow if Regin_ID!=302,av(mean)




///////////////////run SCM Model/////////////////////
//set up time-serie//
gen ndate=string(Date, "%12.0f")
gen date=date(ndate, "YMD")
format date %td

//define panel data//
xtset Regin_ID date

//run SCM//
*1. Outcome variable: total cases*
synth Total_confirmed new_14movavg totalper_14movavg inflow outflow GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(21953) figure nested keep(panelA_total_0105)

*2. Outcome variable: daily new cases*
synth New_Confirmed new_14movavg totalper_14movavg inflow outflow GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(21953) figure nested keep(panelA_new_0105)


****************////Model 2: drop all cities with travel restrictions////****************
cd "/Users/yan/Desktop/COVID_SCM/封关&隔离/three phases/phase1"
log close
log using panel_B.log, replace



drop if Region_EN=="Wenzhou" 
drop if Region_EN=="Zhengzhou"
drop if Region_EN=="Hangzhou"
drop if Region_EN=="Zhumadian"
drop if Region_EN=="Ningbo"
drop if Region_EN=="Harbin"
drop if Region_EN=="Fuzhou"
drop if Region_EN=="Huaian"
drop if Region_EN=="Nantong"
drop if Region_EN=="Xuzhou"
drop if Region_EN=="Nanjing"
drop if Region_EN=="Zhenjiang"
drop if Region_EN=="Linyi"
drop if Region_EN=="Jingdezhen"
drop if Region_EN=="Haikou"
drop if Region_EN=="Nanchang"
drop if Region_EN=="Nanning"
drop if Region_EN=="Suqian"
drop if Region_EN=="Qingdao"
drop if Region_EN=="Kunming"
drop if Region_EN=="Taian"
drop if Region_EN=="Taizhou"
drop if Region_EN=="Shijiazhuang"
drop if Region_EN=="Sanya"
drop if Region_EN=="Yangzhou"
drop if Region_EN=="Jinan"
drop if Region_EN=="Ma'anshan"
drop if Region_EN=="Suzhou"
drop if Region_EN=="Zhuhai"
drop if Region_EN=="Ya'an"
drop if Region_EN=="Shenzhen"
drop if Region_EN=="Hefei"
drop if Region_EN=="Lanzhou"
drop if Region_EN=="Tangshan"
drop if Region_EN=="Guangyuan"
drop if Region_EN=="Chengdu"
drop if Region_EN=="Guiyang"
drop if Region_EN=="Lianyungang"
drop if Region_EN=="Tianjin"
drop if Region_EN=="Guangzhou"
drop if Region_EN=="Suining"
drop if Region_EN=="Ziyang"
drop if Region_EN=="Foshan"
drop if Region_EN=="Huizhou"
drop if Region_EN=="Mianyang"
drop if Region_EN=="Deyang"
drop if Region_EN=="Hanzhong"
drop if Region_EN=="Dongguan"
drop if Region_EN=="Wuxi"
drop if Region_EN=="Shanghai"
drop if Region_EN=="Beijing"
drop if Regin_ID==69
drop if Regin_ID==285
drop if Region_EN=="Tongliao"
drop if Regin_ID==13
drop if Regin_ID==4
drop if Region_EN=="Wuhai"
drop if Regin_ID==113
drop if Regin_ID==312
drop if Region_EN=="Chifeng"
drop if Region_EN=="Baotou"
drop if Regin_ID==298
drop if Region_EN=="Hohhot"

///////////////////run SCM Model/////////////////////
//set up time-serie//
gen nndate=string(Date, "%12.0f")
gen date=date(nndate, "YMD")
format date %td

//define panel data//
xtset Regin_ID date

//run SCM//
*1. Outcome variable: total cases*
synth Total_confirmed total_14movavg totalper_14movavg inflow outflow GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(21953) figure nested keep(panelB_total_0105)

*2. Outcome variable: daily new cases*
synth New_Confirmed total_14movavg totalper_14movavg inflow outflow GDPmillion GDPpercapita popdensity 每万人医院床位数 每万人医生数 TEM RHU1 WINms AQI , trunit(302) trperiod(21953) figure nested keep(panelB_new_0105)





///treatment effect - compare synthetic HK and real HK///
use panelC_new_0106.dta,clear

format %td _time
 
gen effect= _Y_treated - _Y_synthetic

label variable _time "date"

label variable effect "Gap in New Infections"

line effect _time, xline(22042,lp(dash)) yline(0,lp(dash))

