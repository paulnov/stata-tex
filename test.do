
do stata-tex

display "TEMPLATE WITH STARS"
cap erase output_table.tex
table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table.tex) 

display "TEMPLATE WITH STARS SUPPRESSED"
cap erase output_table_no_stars.tex
table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table_no_stars.tex) dropstars


