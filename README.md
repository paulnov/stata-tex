# stata-tex: Create custom LaTeX tables from Stata

It's often necessary to produce an output table that doesn't fit any
of the format provided by the standard tools outreg, esttab, etc..
Some examples: 
- Showing p-values for linear combinations of coefficients 
- Putting certain coefficients in bold 
- Putting different outcome variables in the same row of a regression table 
- Multi-panel tables with different formatting in each panel

Stata-tex allows you to separate the LaTeX table template from the
table data. This lets you set up and compile exactly the LaTeX table
you want, with placeholders for the data. Then you can generate the
data separately, and transfer it into the LaTeX table automatically.

It takes a bit of time to get right on the first time, but everyone on
our team now loves this tool and relies on it for tables of any
complexity. We find it far easier to just write the template we want
rather than trying to figure out esoteric `estout` or `esttab`
parameters.

### Advantages:
- Arbitrary customization of Stata/LaTeX tables
- Iterate on the LaTeX table without regenerating estimates
- Stata code is much much cleaner
- Can get LaTeX table looking right without using Stata
- Easy to copy table templates to new contexts
- One regression can create estimates that are used in many tables

## HOW TO USE

### Step 1

Create a latex table, with placeholders for all the numbers you want
to put in later.  Placeholders are marked with $$, e.g. `$$beta1$$`.  So
you create a regular latex table, with lines like this:

    Treatment           &     $$treatment1_starbeta$$  &     \textbf{$$treatment2_starbeta$$}  &     $$treatment3_starbeta$$  &     \textbf{$$treatment4_starbeta$$}  \\
                        &     $$treatment1_se$$        &     \textbf{$$treatment2_se$$}        &     $$treatment3_se$$        &     \textbf{$$treatment4_se$$}        \\

In this example, `treatment1` and `treatment2` are estimates from different
regressions -- `treatment1_beta` is a placeholder for the first regression
estimate, and `treatment1_se` for the standard error. Notice that estimates
in the second and forth column are customized to be in bold face.

Finish this table (i.e. with `tabular` etc.), until it compiles in
LaTeX in the format you want. The package includes a very simple
sample table in `output_table.tex`.

### Step 2

In Stata, use the post-estimation command `store_est_tpl` (included in
the `stata-tex` package), to generate a CSV file with all the estimation results:

    reg mpg t [...]
    store_est_tpl using sample_table.csv, coef(t) name(treatment2) all

This will append a block to `sample_table.csv` containing the
following lines (with example numbers):

    treatment2_p, 0.00
    treatment2_beta, 0.009
    treatment2_starbeta, 0.009***
    treatment2_se, 0.001
    treatment2_n, 147143
    treatment2_r2, 0.00

Note that the placeholder `beta` holds just the beta coefficient,
while `starbeta` calculates a p-value and shows stars for p<0.1, p<0.05,
p<0.01. e.g. `beta` contains `0.06`, and `starbeta` contains `0.06**`.

`store_est_tpl` takes an optional `format()` parameter that lets you
specify a different format for the coefficient and standard error
(e.g. `"%5.2f"`). The default is 3 decimal points.  p-values and r2
always have 2 decimal points.

The `all` parameter is short for `beta se n p r2` -- the latter let
you choose exactly what estimation statistics you want to
output. Outputting statistics you don't use is fine, so `all` is
usually the right answer.

You can run `store_est_tpl` multiple times following a single
estimation if you want to store multiple coefficients.  If you want to
store some other value in this file, e.g. a p-value from an F test or
significance test for a difference between two coefficients, you can
store an arbitrary string using:

    insert_into_file using sample_table.csv, key(treatment2_ftest) value(0.35) format(%5.2f)

Note that both `store_est_tpl` and `insert_into_file` will replace any
line in the CSV file that currently has the same coefficient
name.

### Step 3

Finally, use `table_from_tpl` to transfer the estimates into the LaTeX
template (via Python):

    table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table.tex) 

t = template file, r = replacement data file, o = output file

You can also optionally add or suppress significance stars from the output file with the following two commands:

    table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table.tex) add_stars
    table_from_tpl, t(treatment_tpl.tex) r(sample_table.csv) o(output_table.tex) drop_stars

This operates by replacing beta with starbeta in the template (or vice
versa) when generating the output file. If you have stars on some
coefficent name other than beta, you will need to create custom
templates with and without stars.

## EXAMPLE

Place all stata-tex files in the same folder, including the sample
template `treatment_tpl.tex`.  `test.do` provides a complete example
using the standard `auto` dataset. It creates two output files:
`output_table.tex` and `output_table_no_stars.tex`.

## LIMITATIONS / KNOWN ISSUES

- Unlike `outreg`, `estout`, etc., you can't add and remove columns from
these tables without modifying the LaTeX template. This is an inherent
limitation of having a totally customizable table template.

- If a placeholder appears multiple times in the output file, only the
first appearance will be used. However, if you are only using
`insert_into_file` and `store_est_tpl`, you should not run into this
as these programs replace existing lines with the same parameter
values (as of 10/30/2018).

- The templates don't compile themselves, because latex interprets the
  replacement markers `$$` and `_` as special characters. I couldn't
  find any clean way around this, but let me know if you have a better
  idea for how to tag replacement strings.

## INSTALLING

table_from_tpl() needs to find table_from_tpl.py either in the current
folder, or in the folder specified by the Stata global macro $PYTHONPATH.

This has been tested most thoroughly with Python 2.7. If you encounter
difficulties with other versions of Python, please let me know.
