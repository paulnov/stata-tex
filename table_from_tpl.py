import os
import sys
from optparse import OptionParser

def parse_options():

    # create option parser
    parser = OptionParser()
    
    # require an input file
    parser.add_option('-t', '--tpl-path', dest='tpl_path',
                      help='path to template file', metavar='templates/table.tex')
    
    parser.add_option('-o', '--out-path', dest='output_path',
                      help='path to output file', metavar='output/table.tex')

    parser.add_option('-r', '--repl-path', dest='replace_path',
                      help='path to string replacement file', metavar='~/foo/replacements.csv')

    parser.add_option('-s', '--add-stars', dest='add_stars', action="store_true", 
                      help='adds stars by replacing beta with starbeta')

    parser.add_option('-d', '--drop-stars', dest='drop_stars', action="store_true", 
                      help='removes stars by replacing starbeta with beta')

    parser.add_option("-v", action="store_true", dest="verbose", help='verbose mode')

    # parse command line
    (options, args) = parser.parse_args()
    
    # crash if no input path specified
    if not options.tpl_path or not options.output_path or not options.replace_path:
        parser.print_help()
        sys.exit(1)

    return options

options = parse_options()

# read template file into a string
if options.verbose:
    print("Reading template %s..." % (os.path.expanduser(options.tpl_path)))

with open (os.path.expanduser(options.tpl_path), "r") as tpl_file:
    tpl_lines = tpl_file.read()
    if options.verbose: print("Success.")

# if stars added or suppressed, then replace beta with starbeta or viceversa
if options.add_stars:

    # two lines so starbeta doesn't turn into starstarbeta
    tpl_lines = tpl_lines.replace("beta$$", "starbeta$$")
    tpl_lines = tpl_lines.replace("_starstarbeta$$", "_starbeta$$")
    
elif options.drop_stars:

    # add $$ suffix since we don't want to turn starbeta -> starstarbeta
    tpl_lines = tpl_lines.replace("starbeta$$", "beta$$")

# go over replacement file line by line
if options.verbose:
    print("Reading replacement file %s..." % (os.path.expanduser(options.replace_path)))

with open(os.path.expanduser(options.replace_path), "r") as f:
    replacements = f.readlines()
    if options.verbose: print("Success.")

# loop over replacement line
for line in replacements:

    # second parameter "1" allows only one split in case there are commas in the replacement string
    (token, value) = line.split(",", 1)

    tpl_lines = tpl_lines.replace("$$%s$$" % (token), value.strip())

# write output path
if options.verbose:
    print("Writing output file %s..." % (os.path.expanduser(options.output_path)))
with open (os.path.expanduser(options.output_path), "w") as output_file:
    output_file.write(tpl_lines)

# check existence of output file
ofile = os.path.expanduser(options.output_path)
if os.path.isfile(ofile): print("Created tex file %s." % (ofile))

if options.verbose:
    print("Contents of %s: " % (ofile))
    with open(ofile, 'r') as outfile:
        for line in outfile:
            print(line)
