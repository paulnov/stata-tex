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

/*************************************************************************************/
/* program store_val_tpl : store value to a file with string and format              */
/*************************************************************************************/
cap prog drop store_val_tpl
prog def store_val_tpl
{
  syntax using/,  Name(string) Value(string) [Format(string)]

  /* set default format if not specified */
  if mi("`format'") local format "%6.3f"

  /* get value in appropriate format (unless it's already a string) */
  if !mi(real("`value'")) {
    local v : di `format' `value'
  }
  else {
    local v `value'
  }

  /* write line to file */
  append_to_file using `using', s("`name',`v'")
}
end
/* *********** END program store_val_tpl ***************************************** */

/***************************************************************************************************/
/* program table_from_tpl : Create a table from a stored estimates file and a .tex table template  */
/***************************************************************************************************/
cap prog drop table_from_tpl
prog def table_from_tpl
{
  syntax, Template(string) Replacement(string) Output(string) [Verbose addstars dropstars]

  /* set up verbose flag */
  if !mi("`verbose'") {
      local v "-v"
  }
  else {
      local v
  }
  
  
  /* if python path is not set, use current folder */
  if mi("$PYTHONPATH") {

      /* set path to current folder */
      local path .
  }
  else {
      local path $PYTHONPATH
  }

  /* check python file existence */
  cap confirm file `path'/table_from_tpl.py
  if _rc {
      display as error "ERROR: table_from_tpl.py not found. Put in current folder or folder defined by global \$PYTHONPATH"
      error -1
  }

  /* deal with addstars/dropstars parameters */
  if "`addstars'" == "addstars" {
    local star_param "--add-stars"
  }
  if "`dropstars'" == "dropstars" {
    local star_param "--drop-stars"
  }  
  
  local pycommand `path'/table_from_tpl.py -t `template' -r `replacement' -o `output' `v' `star_param'
  if !mi("`verbose'") {
      di `"Running `pycommand' "'
  }

  shell python `pycommand'
  cap confirm file `output'
  if !_rc {
    display "Created `output'."
  }
  else {
    display "Could not create `output'."
    error 1
  }

  /* clean up the temporary file if star/nostar specified */
  if !mi("`stars'") {
    !rm $tmp/tpl_sed_tmp.tex
  }
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

/**********************************************************************************/
/* program count_stars : return a string with the right number of stars           */
/**********************************************************************************/
cap prog drop count_stars
prog def count_stars, rclass
{
  syntax, p(real)
  local star = ""
  if `p' <= 0.1  local star = "*"   
  if `p' <= 0.05 local star = "**"  
  if `p' <= 0.01 local star = "***" 
  return local stars = "`star'"
}
end
/* *********** END program count_stars ***************************************** */
