
fs = require('fs');

var i, l, path, className, file, files = [
  "ObjectAbstract",
  "CanvasElementAbstract",
  "Timer",
  "elements/Sprite",
  "elements/Shape",
  "elements/Text",
  "Canvas"
];

var exports = [
  "ObjectAbstract",
  "Timer",
  "Canvas",
  "Sprite",
  "Shape",
  "Text"
];

var data = "";

for(i=0, l=files.length; i<l; i+=1){
  file = files[i];
  path = 'source/'+file+'.coffee';
  className = file.split('/')
  className = className[className.length-1]

  console.log("Bundling: %s", path);

  data += fs.readFileSync(path)
}

data += "\n\nwindow.rippl ="

for(i=0, l=exports.length; i<l; i+=1){
  className = exports[i];
  data += "\n  "+className+": "+className
}

data += "\n\ndefine(window.rippl) if typeof define is 'function'"

console.log("Saving bundled .coffee file")

fs.writeFileSync("../rippl.coffee", data)