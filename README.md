# Rippl

Rippl is a simple html5 canvas library written in CoffeeScript. Ripple works is written as AMD intended to use with require.js.

## Basic use

```coffeescript
rippl = require('rippl')

#
# Take an existing <canvas> tag with id "my-canvas", let's assume that canvas has dimensions of 200x50
#
canvas = new rippl.Canvas(id: "my-canvas")

#
# Add a text label to it and position it at the center of the canvas
#
textElement = canvas.createText
  label: "Hello World!"
  x: 100
  y: 25
  size: 30

#
# Render the canvas to make the text visible, this process should be automated for animations, more on that later...
#
canvas.render()
```

## Installation

Proper folder structure:

```
Root folder
  |
  +-- lib
  |     |
  |     +-- Rippl
  |     |     |
  |     |     +-- Contents of this repo!
  |     |
  |     +-- ... other libs ...
  |
  +-- ... other project stuff ...
```

Add to require.js configuration:

```coffeescript
ObjectAbstract: 'js/lib/Rippl/ObjectAbstract'
rippl: 'js/lib/Rippl/rippl'
```