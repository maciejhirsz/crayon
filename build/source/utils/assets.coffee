
rippl.assets =
  _assets: {}

  # -----------------------------------

  get: (url) ->
    return @_assets[url] if @_assets[url] isnt undefined

    return @_assets[url] = new ImageAsset(url)

  # -----------------------------------

  define: (url, dataurl) ->
    @_assets[url] = new ImageAsset(dataurl)

  # -----------------------------------


  preload: (urls, callback) ->
    urls = [urls] if typeof urls is 'string'

    count = urls.length

    for url in urls
      asset = @get(url)
      if asset.__isLoaded
        count -= 1
        callback() if count is 0

      else
        asset.on 'loaded', ->
          count -= 1
          callback() if count is 0
