
rippl.ImageAsset = class ImageAsset extends ObjectAbstract
  __isAsset: true

  # -----------------------------------

  __isLoaded: false

  # -----------------------------------

  constructor: (url) ->
    @_image = new Image
    @_image.onload = =>
      @__isLoaded = true
      @trigger('loaded')
    @_image.src = url

  # -----------------------------------

  getDocumentElement: ->
    return @_image if @__isLoaded
    return null