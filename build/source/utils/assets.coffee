
rippl.assets =
  _assets: {}

  # -----------------------------------

  get: (url) ->
    return @_assets[url] if @_assets[url] isnt undefined

    return @_assets[url] = new ImageAsset(url)