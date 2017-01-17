/*************************************************************************************/
/* program store_est_tpl : store b, se, p-values in format suitable for table_to_tpl */
/*************************************************************************************/
cap prog drop store_est_tpl
prog def store_est_tpl
{
  syntax using/,  coef(string) name(string) [format(string) beta se p n r2 all]

  /* turn on all flags if `all' is specified */
  if !mi("`all'") {
    local beta beta
    local se se
    local p p
    local n n
    local r2 r2
  }

  /* set default format if not specified */
  if mi("`format'") local format "%6.3f"

  /* manage beta */
  if !mi("`beta'") {
    local b3:  di `format' _b["`coef'"]
    test `coef' = 0

    /* write p value (only makes sense if beta also specified) */
    if !mi("`p'") {
      local p2: di %5.2f `r(p)'
      append_to_file using `using', s("`name'_p,`p2'")
    }

    /* write beta to file */
    append_to_file using `using', s("`name'_beta, `b3'")

    /* count stars on the p and create starbeta */
    count_stars, p(`r(p)')
    append_to_file using `using', s("`name'_starbeta, `b3'`r(stars)'")
  }

  /* manage se */
  if !mi("`se'") {
    local se3:  di `format' _se["`coef'"]
    append_to_file using `using', s("`name'_se, `se3'")
  }
  
  /* manage n */
  if !mi("`n'") {
    append_to_file using `using', s("`name'_n, `e(N)'")
  }

  /* manage r2 */
  if !mi("`r2'") {
    local r2:  di %5.2f `e(r2)'
    append_to_file using `using', s("`name'_r2, `r2'")
  }
}
end
/* *********** END program store_est_tpl ***************************************** */

/***************************************************************************************************/
/* program table_from_tpl : Create a table from a stored estimates file and a .tex table template  */
/***************************************************************************************************/
cap prog drop table_from_tpl
prog def table_from_tpl
{
  syntax, Template(string) Replacement(string) Output(string)

  shell python table_from_tpl.py -t `template' -r `replacement' -o `output'
}
end
/* *********** END program table_from_tpl ***************************************** */

/**********************************************************************************/
/* program append_to_file : Append a passed in string to a file                   */
/**********************************************************************************/
cap prog drop append_to_file
prog def append_to_file
{
  syntax using/, String(string)

  cap file close fh
  file open fh using `using', write append
  file write fh  `"`string'"'  _n
  file close fh 
}
end
/* *********** END program append_to_file ***************************************** */
