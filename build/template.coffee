###
(c) 2012-2013 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
###

window.rippl = rippl = {}

#!include ObjectAbstract.coffee
#!include utils/Timer.coffee
#!include utils/Color.coffee
#!include utils/Point.coffee
#!include utils/Transformation.coffee
#!include utils/ImageAsset.coffee
#!include utils/assets.coffee
#!include utils/filters.coffee
#!include elements/Element.coffee
#!include elements/Sprite.coffee
#!include elements/Shape.coffee
#!include elements/Text.coffee
#!include elements/Rectangle.coffee
#!include elements/Circle.coffee
#!include elements/Ellipse.coffee
#!include elements/CustomShape.coffee
#!include Canvas.coffee

define('rippl', window.rippl) if typeof define is 'function'