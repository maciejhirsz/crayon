#!/bin/bash

coffee bundle.coffee

echo "  > Compile rippl.coffee to rippl.js"
coffee --compile --output ../ ../rippl.coffee

echo "  > Uglify the JavaScript"
uglifyjs2 ../rippl.js -o ../rippl.min.js

echo ""