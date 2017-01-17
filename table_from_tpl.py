import os
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

    # parse command line
    (options, args) = parser.parse_args()
    
    # crash if no input path specified
    if not options.tpl_path or not options.output_path or not options.replace_path:
        parser.print_help()
        sys.exit(1)

    return options

options = parse_options()

# read template file into a string
with open (os.path.expanduser(options.tpl_path), "r") as tpl_file:
    tpl_lines = tpl_file.read()

# go over replacement file line by line
with open(os.path.expanduser(options.replace_path), "r") as f:
    replacements = f.readlines()

for line in replacements:
    (token, value) = line.split(",")

    tpl_lines = tpl_lines.replace("$$%s$$" % (token), value.strip())

with open (os.path.expanduser(options.output_path), "w") as output_file:
    output_file.write(tpl_lines)

