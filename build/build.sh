#!/bin/bash

node bundle.js

echo "  > Uglify the JavaScript"
uglifyjs2 ../crayon.js -o ../crayon.min.js

echo ""