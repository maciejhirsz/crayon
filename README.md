# Rippl

Rippl is a simple html5 canvas library written in CoffeeScript. Ripple can be used either as standalone library or as AMD with require.js.

## Basic use

You can use Rippl to render static images:

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
# Render the canvas to make the text visible
#
canvas.render()
```

Or for animations:

```coffeescript
rippl = require('rippl')

#
# Do everything as in the example above
#
canvas = new rippl.Canvas(id: "my-canvas")

textElement = canvas.createText
  label: "Hello World!"
  x: 100
  y: 25
  size: 30

#
# But instead of rendering the canvas we bind it to a timer
#
#   note: you can bind more than one canvas to one timer
#
timer = new rippl.Timer
timer.bind(canvas)

#
# Using the timer's "frame" event we can easily give our label a blob effect
#
timer.on 'frame', (time) ->
  #
  # Original time is in milliseconds
  #
  t = time / 1000
  sin = Math.sin(t * 4)

  textElement.setScale(0.95 + sin / 10, 0.95 - sin / 10)
```
