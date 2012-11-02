###
(c) 2012 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
###

(->
  #!include ObjectAbstract.coffee
  #!include Transformation.coffee
  #!include CanvasElementAbstract.coffee
  #!include Timer.coffee
  #!include elements/Sprite.coffee
  #!include elements/Shape.coffee
  #!include elements/Text.coffee
  #!include Canvas.coffee

  window.rippl =
    ObjectAbstract: ObjectAbstract
    Timer: Timer
    Canvas: Canvas
    Sprite: Sprite
    Shape: Shape
    Text: Text
)(window)

define(window.rippl) if typeof define is 'function'