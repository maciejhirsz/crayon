
rippl.Point = class Point
  x: 0
  y: 0

  # -----------------------------------

  __isPoint: true

  # -----------------------------------

  canvas: null

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
    @x = x if x isnt null
    @y = y if y isnt null
    @canvas.touch() if @canvas isnt null
    @
