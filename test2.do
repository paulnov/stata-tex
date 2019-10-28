do stata-tex
set seed 123

sysuse auto, clear

/* create several placebo treatment variables */
gen t1 = uniform() < 0.5
gen t2 = uniform() < 0.5
gen t3 = uniform() < 0.5
gen t4 = uniform() < 0.5

/* simulate treatment effects one effect is very large to test formatting of long numbers  */
replace mpg = mpg + 2 if t2
replace mpg = mpg + 20000000 if t4

/* run some regressions and store some estimates */
reg mpg t1
store_est_tpl using sample_table.csv, coef(t1) name(treatment1) all format(%15.0fc)

reg mpg t2
store_est_tpl using sample_table.csv, coef(t2) name(treatment2) all format(%15.0fc)

reg mpg t3
store_est_tpl using sample_table.csv, coef(t3) name(treatment3) all format(%15.0fc)

reg mpg t4
store_est_tpl using sample_table.csv, coef(t4) name(treatment4) all format(%15.0fc)

cat sample_table.csv

display "TEMPLATE WITH STARS"
cap erase output_table.tex
table_from_tpl, template(treatment_tpl.tex) replacement(sample_table.csv) output(output_table.tex) 

display "TEMPLATE WITH STARS SUPPRESSED"
cap erase output_table_no_stars.tex
table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table_no_stars.tex) dropstars


