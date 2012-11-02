
fs = require('fs')

console.log("")
console.log("  > Parsing the template!")

template = fs.readFileSync('template.coffee').toString()

includePattern = RegExp('([ \t]*)\#\!include[ ]+([^ \n\r\t]+)', 'ig')
linePattern = RegExp('[^\n]+', 'ig')

template = template.replace includePattern, (match, indent, path) ->
  console.log("    + include ./source/#{path}")
  fs.readFileSync("./source/#{path}").toString().replace linePattern, (match) ->
    #
    # Add indents to new lines
    #
    indent+match

console.log("  > Saving bundled rippl.coffee file")

fs.writeFileSync("../rippl.coffee", template)