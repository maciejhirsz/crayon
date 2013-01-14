
rippl.Point = class Point
  x: 0
  y: 0

  # -----------------------------------

  __isPoint: true

  # -----------------------------------

  constructor: (x, y) ->
    @x = x
    @y = y

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @

  # -----------------------------------

  move: (x, y) ->
    @x = x
    @y = y
    @canvas.touch() if @canvas isnt undefined
    @
