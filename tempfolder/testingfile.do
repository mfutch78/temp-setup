clear
cd /Users/michaelfutch/bluelabs/turnout/elections


use us_states
replace state = trim(state)

merge 1:1 state using senate_class, gen(m_class)



sort state

forvalues i=1(1)3{
	rename class`i' cand`i'
	gen class`i' = 0
	replace class`i' = 1 if cand`i' != "Ñ"
}
