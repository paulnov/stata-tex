do ~/iecmerge/include/stata-tex/stata-tex.do

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
table_from_tpl, t(~/iecmerge/include/stata-tex/two_panel.tex) r(`data') o($tmp/output_table.tex)

cat $tmp/output_table.tex
