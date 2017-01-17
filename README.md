# stata-tex A set of tools to make it easier to create complicated LaTeX tables from Stata

It's often necessary to produce an output table that doesn't fit any
of the format provided by the standard tools outreg, esttab, etc..
Some examples: 
- Showing p-values for differences of coefficients 
- Putting certain coefficients in bold 
- Putting different outcome variables in the same row of a regression table 
- Multi-panel tables with different formatting in each panel

Stata-tex allows you to separate the LaTeX table template from the
table data. This lets you set up and compile exactly the LaTeX table
you want, with placeholders for the data. Then you can generate the
data separately, and transfer it into the LaTeX table automatically.

Advantages:
- can iterate on the LaTeX table without regenerating estimates
- Stata code is much much cleaner
- Can modify the latex table template directly

HOW TO USE

Step 1

Create a latex table, with placeholders for all the numbers you want
to put in later.  Placeholders are marked with $$, e.g. $$beta1$$.  So
you create a regular latex table, with lines like this:

New Road & $$app1_beta$$ & $$app2_beta$$ \\ & $$app1_se$$ &
          $$app2_se$$ \\

In this example, "app1" and "app2" are estimates from different
regressions.

Compile this table in latex until satisfied with the format.

Step 2

In Stata, create a data file with the content for the table, in the
following format:

app1_p, 0.71
app1_beta, -0.000
app1_starbeta, -0.000
app1_se, 0.001
app1_n, 143998
app1_r2, 0.00
app2_p, 0.00
app2_beta, 0.009
app2_starbeta, 0.009***
app2_se, 0.001
app2_n, 147143
app2_r2, 0.00

The post-estimation command store_est_tpl will generate this file
automatically. Following an estimation, the command:

store_est_tpl using $tmp/regdata.csv, coef(treatment_comp) name(app1) all

writes the top six lines to the above file for you. Note that the
placeholder "beta" holds just the beta coefficient, while starbeta
calculates a p-value and shows stars for p<0.1, p<0.05, p<0.01.

store_est_tpl takes an optional format() parameter that lets you
specify a different format for the beta and standard error
(e.g. "%5.2f" -- the default is 3 decimal points).  p-values and r2
always have 2 decimal points.

The "all" parameter is short for "beta se n p r2" -- the latter let you
choose exactly what estimation statistics you want to
output. Outputting statistics you don't use is fine.

If you want to store some other value in this file, e.g. a p-value
from an F test or significance test for a difference between two
coefficients, you can store an arbitrary string using:

append_to_file using $tmp/regdata.csv, s("app2_ftest, 0.35")

Step 3

Finally, the table_from_tpl command calls a python program that
transfers the estimates into the latex template:

table_from_tpl, t(~/iecmerge/misc/samples/two_panel.tex)
r($tmp/regdata.csv) o($tmp/output_table.tex)

t = template file
r = replacement data file
o = output file

The easiest way to see how this works may be to work through the
example file table_tpl.do and two_panel.tex that creates a contrived
two panel output table from a system dataset.

