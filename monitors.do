clear
set mem 1000m

cd /Users/michaelfutch/chicagopublic/monitors


/* Insheet raw ozone monitoring data */
forvalues i=2001(1)2014{
	clear
	insheet using ./ozone/ozone`i'.csv, comma names	
	save ./ozone/ozone`i', replace
}


/* Insheet PM10 data */
forvalues i=2001(1)2013{
	clear
	insheet using ./particulates/pm`i'.csv, comma names
	save ./particulates/pm`i', replace
}

/* Insheet PM2.5 data */
forvalues i=2001(1)2014{
	clear
	insheet using ./particulates/pm25_`i'.csv, comma names
	save ./particulates/pm25_`i', replace
}


/* Appending datasets to create monitoring panels */

use ./particulates/pm25_2001, clear

forvalues i=2002(1)2014{
	append using ./particulates/pm25_`i'
}

preserve
collapse site_lat site_lon, by(aqs_site_id)
outsheet using pm25_monitor_locations.csv, comma replace
restore

gen date1 = date(date,"MDY")
drop date
rename date1 date
order date
format date %td
gen academic_year = yofd(date) if month(date)<=6
replace academic_year = yofd(date) + 1 if academic_year == .
gen year = yofd(date) 

gen above_thresh = dailymeanpm25 > 12.0
gen above_24hr_thresh = dailymeanpm25 > 35.0

save ./particulates/pm25_data, replace

twoway lowess dailymeanpm25concentration date if county == "Cook" & /// 
poc == 1 & aqs_site_id != "17-031-6005" & aqs_site_id != "17-031-0014" || lowess dailymeanpm25concentration date if poc == 1 & (aqs_site_id =="17-031-6005" | aqs_site_id == "17-031-0014"), legend(lab(1 "Cook County") lab(2 "Near Fisk"))

tostring poc, replace
egen panelvar = concat(aqs_site_id poc)
duplicates drop panelvar date, force
encode panelvar, gen(panelvar2)

tsset panelvar2 date
twoway tsline dailymeanpm25concentration if county == "Cook" & /// 
aqs_site_id != "17-031-1016" & aqs_site_id != "17-031-3301" & aqs_site_id != "17-031-6006" || tsline dailymeanpm25concentration  if  (aqs_site_id == "17-031-1016" | aqs_site_id == "17-031-3301" | aqs_site_id == "17-031-6006"), legend(lab(1 "Cook County") lab(2 "Near Fisk")) 

twoway tsline dailymeanpm25concentration if county == "Cook" 

sort aqs_site_id date poc
duplicates drop aqs_site_id date, force

bysort aqs_site_id year: gen numobs = _N

gen count = 1
collapse dailymeanpm25 site_lat site_lon (sum) count above_thresh above_24hr_thresh , by(aqs_site_id year)

gen above_thresh_prorate = above_thresh*(365/count)
gen above_24hr_thresh_prorate = above_24hr_thresh*(365/count)


save ./particulates/pm25_monitor_long, replace



sort aqs_site_id academic_year
drop count above_thresh above_24hr_thresh
rename dailymean dailymean_
rename above_thresh_prorate days_above_12_
rename above_24hr_thresh days_above_35_
reshape wide dailymean days_above*, i(aqs_site_id) j(academic_year)

gen n= _n
order n aqs_site_id
*keep n aqs_site_id site_lat site_lon
outsheet using ./particulates/pm25_monitor_wide.csv, comma replace noquote
save ./particulates/pm25_monitor_wide, replace


use ./particulates/pm2001, clear

forvalues i=2002(1)2013{
	append using ./particulates/pm`i'
}


gen date1 = date(date,"MDY")
drop date
rename date1 date
order date
format date %td
gen academic_year = yofd(date) if month(date)<=6
replace academic_year = yofd(date) + 1 if academic_year == .


save ./particulates/pm_data, replace


preserve
/* Only temporarily dropping secondary monitors */
duplicates drop aqs_site_id date, force
bysort date: gen daily_num_monitors = _N
keep if date == 15354
outsheet date aqs_site_id site_latitude site_longitude dailymeanpm10 daily_aqi_value  using ./particulates/pm_data.csv, comma replace 
restore

gen year = yofd(date)


gen minyear = year
gen maxyear = year

collapse site_latitude site_longitude dailymeanpm10 daily_aqi_value (min) minyear (max) maxyear, by(aqs_site_id)
outsheet using ./particulates/pm_monitors.csv, comma replace noquote

use ./ozone/ozone2001, clear

forvalues i=2002(1)2014{
	append using ./ozone/ozone`i'
}

gen date1 = date(date,"MDY")
drop date
rename date1 date
order date
format date %td
gen academic_year = yofd(date) if month(date)<=6
replace academic_year = yofd(date) + 1 if academic_year == .

save ./ozone/ozone_data, replace


preserve
/* Only temporarily dropping secondary monitors */
duplicates drop aqs_site_id date, force
bysort date: gen daily_num_monitors = _N


rename dailymax8hourozoneconcentration dailymaxOz
outsheet date aqs_site_id  dailymaxOz daily_aqi_value  ///
  using ./ozone/ozone_data.csv, comma replace
restore


gen year = yofd(date)

gen minyear = year
gen maxyear = year

collapse site_latitude site_longitude (min) minyear (max) maxyear, by(aqs_site_id)
outsheet using ./ozone/ozone_monitors.csv, comma replace noquote


***** PM 2.5 data *****

use ./particulates/pm25_2001, clear

forvalues i=2002(1)2013{
	append using ./particulates/pm25_`i'
}


gen date1 = date(date,"MDY")
drop date
rename date1 date
order date
format date %td
gen academic_year = yofd(date) if month(date)<=6
replace academic_year = yofd(date) + 1 if academic_year == .


save ./particulates/pm25_data, replace



gen year = yofd(date)


gen minyear = year
gen maxyear = year

collapse site_latitude site_longitude dailymeanpm25 daily_aqi_value (min) minyear (max) maxyear, by(aqs_site_id)
outsheet using ./particulates/pm25_monitors.csv, comma replace noquote




