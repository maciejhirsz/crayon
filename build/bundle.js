var fs = require('fs');

console.log("");
console.log("  > Parsing the template!");

var template       = fs.readFileSync('template.js').toString(),
    includePattern = /([\t ]*)\/\*\*\s*@include\s*\{(.*?)\}\s*\*\//ig,
    linePattern    = /[^\n\r]+/gm;

template = template.replace(includePattern, function(match, indent, path) {
    console.log("    + include ./source/" + path);

    var data =
            indent + "/**\n" +
            indent + " * Begin contents of {" + path + "}\n" +
            indent + " */\n";

    data += fs.readFileSync("./source/" + path).toString().replace(linePattern, function(match) {
        return indent + match;
    });

    data += "\n" +
        indent + "/**\n" +
        indent + " * End contents of {" + path + "}\n" +
        indent + " */\n";

    return data;
});

console.log("  > Saving bundled crayon.js file");

fs.writeFileSync("../crayon.js", template);