((rippl) ->

  rgbToLuma = (r, g, b) ->
    0.30 * r + 0.59 * g + 0.11 * b

  # -----------------------------------

  rgbToChroma = (r, g, b) ->
    Math.max(r, g, b) - Math.min(r, g, b)

  # -----------------------------------

  rgbToLumaChromaHue = (r, g, b) ->
    luma = rgbToLuma(r, g, b)
    chroma = rgbToChroma(r, g, b)

    if chroma is 0
      hprime = 0
    else if r is max
      hprime = ((g - b) / chroma) % 6
    else if g is max
      hprime = ((b - r) / chroma) + 2
    else if b is max
      hprime = ((r - g) / chroma) + 4

    hue = hprime * (Math.PI / 3)
    [luma, chroma, hue]

  # -----------------------------------

  lumaChromaHueToRgb = (luma, chroma, hue) ->
    hprime = hue / (Math.PI / 3)
    x = chroma * (1 - Math.abs(hprime % 2 - 1))
    sextant = ~~hprime

    switch sextant
      when 0
        r = chroma
        g = x
        b = 0
      when 1
        r = x
        g = chroma
        b = 0
      when 2
        r = 0
        g = chroma
        b = x
      when 3
        r = 0
        g = x
        b = chroma
      when 4
        r = x
        g = 0
        b = chroma
      when 5
        r = chroma
        g = 0
        b = x

    component = luma - rgbToLuma(r, g, b)

    r += component
    g += component
    b += component
    [r,g,b]

  #######################

  rippl.filters =
    colorOverlay: (color) ->
      color = new Color(color) if not color.__isColor

      ctx = @ctx
      ctx.save()
      ctx.globalCompositeOperation = 'source-atop'
      ctx.fillStyle = color.toString()
      ctx.fillRect(0, 0, @_width, @_height)
      ctx.restore()

    # -----------------------------------

    invertColors: ->
      @rgbaFilter (r, g, b, a) ->
        r = 255 - r
        g = 255 - g
        b = 255 - b
        [r, g, b, a]

    # -----------------------------------

    saturation: (saturation) ->
      saturation += 1
      grayscale = 1 - saturation

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)

        r = r * saturation + luma * grayscale
        g = g * saturation + luma * grayscale
        b = b * saturation + luma * grayscale
        [r, g, b, a]

    # -----------------------------------

    contrast: (contrast) ->
      gray = -contrast
      original = 1 + contrast

      @rgbaFilter (r, g, b, a) ->
        r = r * original + 127 * gray
        g = g * original + 127 * gray
        b = b * original + 127 * gray
        [r, g, b, a]

    # -----------------------------------

    brightness: (brightness) ->
      change = 255 * brightness

      @rgbaFilter (r, g, b, a) ->
        r += change
        g += change
        b += change
        [r, g, b, a]

    # -----------------------------------

    gamma: (gamma) ->
      gamma += 1

      @rgbaFilter (r, g, b, a) ->
        r *= gamma
        g *= gamma
        b *= gamma
        [r, g, b, a]

    # -----------------------------------

    hueShift: (shift) ->
      fullAngle = Math.PI * 2
      shift = shift % fullAngle

      @rgbaFilter (r, g, b, a) =>
        [luma, chroma, hue] = rgbToLumaChromaHue(r, g, b)

        hue = (hue + shift) % fullAngle
        hue += fullAngle if hue < 0

        [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        [r, g, b, a]

    # -----------------------------------

    colorize: (hue) ->
      hue = hue % (Math.PI * 2)

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)
        chroma = rgbToChroma(r, g, b)
        [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        [r, g, b, a]

    # -----------------------------------

    ghost: (alpha, hue) ->
      opacity = 1 - alpha

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)
        if typeof hue is 'number'
          chroma = rgbToChroma(r, g, b)
          [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        a = (a / 255) * (luma * alpha + 255 * opacity)
        [r, g, b, a]

)(rippl)