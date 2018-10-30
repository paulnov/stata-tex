do stata-tex.do

/* create a simple two panel table */
sysuse auto, clear

/* split price into quartiles */
sum price, d
gen price_q1 = price < `r(p25)'
gen price_q2 = inrange(price, `r(p25)', `r(p50)')
gen price_q3 = inrange(price, `r(p50)', `r(p75)')
gen price_q4 = price > `r(p75)' & !mi(price)

/* regress mpg on price by quartile, and weight on price by quartile */
tempfile data

eststo clear
foreach v in mpg weight {
  
  forval i = 1/4 {
    reg `v' price if price_q`i' == 1
    store_est_tpl using `data', coef(price) name(`v'`i') all
  }
}

/* display generated data */
cat `data'

/* create table */
table_from_tpl, t(two_panel.tex) r(`data') o(output_table.tex)

/* show the result */
cat output_table.tex


reg mpg treatment if sample == 1
store_est_tpl using table-data.csv, coef(treatment) name(treatment1) all

reg mpg treatment if sample == 2
store_est_tpl using table-data.csv, coef(treatment) name(treatment2) all

