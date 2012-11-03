
rippl.ImageAsset = class ImageAsset extends ObjectAbstract
  __isAsset: true

  # -----------------------------------

  isLoaded: false

  # -----------------------------------

  constructor: (url) ->
    @_image = new Image
    @_image.onload = =>
      @isLoaded = true
      @trigger('loaded')
    @_image.src = url

  # -----------------------------------

  getDocumentElement: ->
    return @_image if @isLoaded
    return null