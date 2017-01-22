# stata-tex: Create custom LaTeX tables from Stata

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

### Advantages:
- Arbitrary customization of Stata/LaTeX tables
- Iterate on the LaTeX table without regenerating estimates
- Stata code is much much cleaner
- Can get LaTeX table looking right without using Stata
- Easier to copy table templates to new contexts

## HOW TO USE

### Step 1

Create a latex table, with placeholders for all the numbers you want
to put in later.  Placeholders are marked with $$, e.g. `$$beta1$$`.  So
you create a regular latex table, with lines like this:

    New Road & $$app1_beta$$ & $$app2_beta$$ \\ & $$app1_se$$ & $$app2_se$$ \\

In this example, `app1` and `app2` are estimates from different
regressions -- `app1_beta` is a placeholder for the regression estimate,
and `app1_se` for the standard error.

Compile this table in LaTeX until satisfied with the format.

### Step 2

In Stata, generate a data file with the table estimates in CSV format:

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

The post-estimation command `store_est_tpl` generates this file
automatically. Following an estimation, the command:

    store_est_tpl using table_data.csv, coef(treatment_comp) name(app1) all

writes the top six lines to the above file for you. Note that the
placeholder `beta` holds just the beta coefficient, while starbeta
calculates a p-value and shows stars for p<0.1, p<0.05,
p<0.01. e.g. `beta` contains `0.06`, and `starbeta` contains `0.06**`.

`store_est_tpl` takes an optional `format()` parameter that lets you
specify a different format for the coefficient and standard error
(e.g. `"%5.2f"` -- the default is 3 decimal points).  p-values and r2
always have 2 decimal points.

The `all` parameter is short for `beta se n p r2` -- the latter let
you choose exactly what estimation statistics you want to
output. Outputting statistics you don't use is fine, so `all` is
usually the right answer.

If you want to store some other value in this file, e.g. a p-value
from an F test or significance test for a difference between two
coefficients, you can store an arbitrary string using:

    append_to_file using table_data.csv, s("app2_ftest, 0.35")

### Step 3

Finally, use `table_from_tpl` to transfer the estimates into the LaTeX
template (via Python):

    table_from_tpl, t(two_panel.tex) r(table_data.csv) o(output_table.tex)

t = template file, r = replacement data file, o = output file

The easiest way to get this running may be to work through the example
files `table_tpl.do` and `two_panel.tex` which create a contrived two
panel output table from a system dataset.

## LIMITATIONS

- Unlike `outreg`, `estout`, etc., you can't add and remove columns from
these tables without modifying the LaTeX template. This is an inherent
limitation of having a totally customizable table template.

- If a placeholder appears multiple times in the output file, the first
appearance will be used.  So you need to delete the output file each
time you generate data. (It would probably be better to use the last
appearance, then you could just keep adding to the same estimate data
file.)

## INSTALLING

The default configuration requires the .do file and .py in the current
directory. To set a different path to the python file, set a path to
the Python file in the `table_from_tpl` program in `stata-tex.do`. On
our server, we have hardcoded paths to where these files reside in the
programs themselves, so that they do not have to be in the current
folder of every project.

