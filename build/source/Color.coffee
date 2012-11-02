
  rippl.Color = class Color
    r: 255
    g: 255
    b: 255
    a: 255

    # -----------------------------------

    __isColor: true

    # -----------------------------------

    string: '#ffffff'

    # -----------------------------------

    constructor: (r, g, b, a) ->
      if typeof r is 'string' and r[0] is '#'
        hash = r

        l = hash.length
        if l is 7
          r = parseInt(hash[1..2], 16)
          g = parseInt(hash[3..4], 16)
          b = parseInt(hash[5..6], 16)
        else if l is 4
          r = parseInt(hash[1]+hash[1], 16)
          g = parseInt(hash[2]+hash[2], 16)
          b = parseInt(hash[3]+hash[3], 16)

      @set(r, g, b, a)

    # -----------------------------------

    set: (r, g, b, a) ->
      #
      # Tilde is way more performant than Math.floor
      #
      @r = ~~r
      @g = ~~g
      @b = ~~b
      @a = ~~a if a isnt undefined
      @cacheString()

    # -----------------------------------

    cacheString: ->
      @string = "rgba(#{@r},#{@g},#{@b},#{@a})"

    # -----------------------------------

    toString: ->
      @string
