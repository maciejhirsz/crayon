
fs = require('fs')

console.log("")
console.log("  > Parsing the template!")

template = fs.readFileSync('template.coffee').toString()

pattern = RegExp('[ ]*\#\!include[ ]+([^ \n\r\t]+)', 'ig')

template = template.replace pattern, (match, path) ->
  console.log("    + include ./source/#{path}")
  fs.readFileSync("./source/#{path}").toString()


console.log("  > Saving bundled rippl.coffee file")

fs.writeFileSync("../rippl.coffee", template)