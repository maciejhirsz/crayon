
rippl.RelativePoint = class RelativePoint extends ObjectAbstract
  x: 0
  y: 0

  # -----------------------------------

  vectorX: 0
  vectorY: 0

  # -----------------------------------

  root: null

  # -----------------------------------

  __isPoint: true

  # -----------------------------------

  canvas: null

  # -----------------------------------

  constructor: (x, y, root) ->
    throw "Tried to create a RelativePoint with invalid root Point" if not root.__isPoint

    @x = x + root.x
    @y = y + root.y
    @vectorX = x
    @vectorY = y
    @root = root

    root.on 'move', (root) =>
      @x = root.x + @vectorX
      @y = root.y + @vectorY
      @trigger('move', @)

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @

  # -----------------------------------

  move: (x, y) ->
    if x isnt null
      @x = @root.x + x
      @vectorX = x

    if y isnt null
      @y = @root.y + y
      @vectorY = y

    @canvas.touch() if @canvas isnt null
    @trigger('move', @)
    @
