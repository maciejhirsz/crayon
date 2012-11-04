###
(c) 2012 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
###

(->
  window.rippl = rippl = {}

  #!include ObjectAbstract.coffee
  #!include utils/Timer.coffee
  #!include utils/Color.coffee
  #!include utils/Transformation.coffee
  #!include utils/ImageAsset.coffee
  #!include utils/assets.coffee
  #!include elements/Element.coffee
  #!include elements/Sprite.coffee
  #!include elements/Shape.coffee
  #!include elements/Text.coffee
  #!include Canvas.coffee

)(window)

define(window.rippl) if typeof define is 'function'