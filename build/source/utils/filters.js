(function(crayon) {
    function rgbToLuma(r, g, b) {
        return 0.30 * r + 0.59 * g + 0.11 * b;
    }

    function rgbToChroma(r, g, b) {
        return Math.max(r, g, b) - Math.min(r, g, b);
    }

    function rgbToLumaChromaHue(r, g, b) {
        var luma   = rgbToLuma(r, g, b),
            chroma = rgbToChroma(r, g, b),
            hprime, hue;

        if (chroma === 0) {
            hprime = 0;
        } else if (r === max) {
            hprime = ((g - b) / chroma) % 6;
        } else if (g === max) {
            hprime = ((b - r) / chroma) + 2;
        } else if (b === max) {
            hprime = ((r - g) / chroma) + 4;
        }

        hue = hprime * (Math.PI / 3);
        return [luma, chroma, hue];
    }

    function lumaChromaHueToRgb(luma, chroma, hue) {
        var hprime  = hue / (Math.PI / 3),
            x       = chroma * (1 - Math.abs(hprime % 2 - 1)),
            sextant = ~~hprime,
            r, g, b;

        switch (sextant) {
            case 0:
                r = chroma;
                g = x;
                b = 0;
                break;
            case 1:
                r = x;
                g = chroma;
                b = 0;
                break;
            case 2:
                r = 0;
                g = chroma;
                b = x;
                break;
            case 3:
                r = 0;
                g = x;
                b = chroma;
                break;
            case 4:
                r = x;
                g = 0;
                b = chroma;
                break;
            case 5:
                r = chroma;
                g = 0;
                b = x;
        }
        var component = luma - rgbToLuma(r, g, b);
        r += component;
        g += component;
        b += component;
        return [r, g, b];
    }

    crayon.filters = {
        colorOverlay : function colorOverlay(color) {
            if (!color.__isColor) color = new Color(color);
            var ctx = this.ctx;
            ctx.save();
            ctx.globalCompositeOperation = 'source-atop';
            ctx.fillStyle = color.toString();
            ctx.fillRect(0, 0, this._width, this._height);
            return ctx.restore();
        },

        invertColors : function invertColors() {
            this.rgbaFilter(function(rgba) {
                rgba[0] = 255 - rgba[0];
                rgba[1] = 255 - rgba[1];
                rgba[2] = 255 - rgba[2];
            });
        },

        saturation : function saturation(saturation) {
            saturation += 1;
            var greyscale = 1 - saturation;
            this.rgbaFilter(function(rgba) {
                var luma = rgbToLuma.apply(null, rgba);
                rgba[0] = rgba[0] * saturation + luma * greyscale;
                rgba[1] = rgba[1] * saturation + luma * greyscale;
                rgba[2] = rgba[2] * saturation + luma * greyscale;
            });
        },

        contrast : function contrast(contrast) {
            var grey     = -contrast,
                original = 1 + contrast;

            this.rgbaFilter(function(rgba) {
                rgba[0] = rgba[0] * original + 127 * grey;
                rgba[1] = rgba[1] * original + 127 * grey;
                rgba[2] = rgba[2] * original + 127 * grey;
            });
        },

        brightness : function brightness(brightness) {
            var change = 255 * brightness;
            this.rgbaFilter(function(rgba) {
                rgba[0] += change;
                rgba[1] += change;
                rgba[2] += change;
            });
        },

        gamma : function gamma(gamma) {
            gamma += 1;
            this.rgbaFilter(function(rgba) {
                rgba[0] *= gamma;
                rgba[1] *= gamma;
                rgba[2] *= gamma;
            });
        },

        hueShift : function hueShift(shift) {
            var fullAngle = Math.PI * 2;
            shift = shift % fullAngle;
            this.rgbaFilter(function(rgba) {
                var lumaChromaHue = rgbToLumaChromaHue.apply(null, rgba),
                    luma          = lumaChromaHue[0],
                    chroma        = lumaChromaHue[1],
                    hue           = lumaChromaHue[2];

                hue = (hue + shift) % fullAngle;
                if (hue < 0) hue += fullAngle;
                var rgb = lumaChromaHueToRgb(luma, chroma, hue);
                rgba[0] = rgb[0];
                rgba[1] = rgb[1];
                rgba[2] = rgb[2];
            });
        },

        colorize : function colorize(hue) {
            hue = hue % (Math.PI * 2);
            this.rgbaFilter(function(rgba) {
                var luma   = rgbToLuma.apply(null, rgba),
                    chroma = rgbToChroma.apply(null, rgba),
                    rgb    = lumaChromaHueToRgb(luma, chroma, hue);

                rgba[0] = rgb[0];
                rgba[1] = rgb[1];
                rgba[2] = rgb[2];
            });
        },

        ghost : function ghost(alpha, hue) {
            var opacity = 1 - alpha;
            return this.rgbaFilter(function(rgba) {
                var luma = rgbToLuma.apply(null, rgba);
                if (typeof hue === 'number') {
                    var chroma = rgbToChroma.apply(null, rgba),
                        rgb = lumaChromaHueToRgb(luma, chroma, hue);
                    rgba[0] = rgb[0];
                    rgba[1] = rgb[1];
                    rgba[2] = rgb[2];
                }
                rgba[3] = (a / 255) * (luma * alpha + 255 * opacity);
            });
        }
    };
})(crayon);