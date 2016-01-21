/**
 * @author Maciej Hirsz
 *
 * crayon may be freely distributed under the MIT license.
*/

(function() {
    'use strict';

    var crayon = {};

    /**
     * Begin contents of {tools.js}
     */
    // Object.assign polyfill for IE
    if (typeof Object.assign !== 'function') Object.assign = function assign(target) {
        var len = arguments.length, i, key, source;
        if (len < 2) return target;

        for (i = 1; i < len; i++) {
            source = arguments[i];
            if (source == null) continue;
            for (key in source) {
                if (source.hasOwnProperty(key)) target[key] = source[key];
            }
        }

        return target;
    };

    /**
     * Extends the prototype of `SubClass` by the prototype of the `SuperClass`
     *
     * @param {function} SubClass
     * @param {function} SuperClass
     */
    function extend(SubClass, SuperClass) {
        SubClass.prototype = Object.create(SuperClass.prototype, {
            constructor: {
                value: SubClass,
                enumerable: false,
                writable: true,
                configurable: true
            }
        });
    }

    /**
     * Creates a frozen `defaults` member on the prototype of the `Class`
     * constructor function, extending defaults imported from any superclass.
     *
     * @param {function} Class
     * @param {object} defaults
     */
    function defaults(Class, defaults) {
        Object.defineProperty(Class.prototype, 'defaults', {
            enumerable : true,
            value      : Object.freeze(Object.assign({}, Class.prototype.defaults, defaults))
        });
    }

    /**
     * Assigns named functions passed to this function as extra arguments
     * as methods on the prototype of the constructor function `Class`
     *
     * @param {function} Class
     */
    function methods(Class) {
        var len = arguments.length, i, method;
        if (len < 2) return;

        for (i = 0; i < len; i++) {
            method = arguments[i];
            if (typeof method !== 'function' || method.name == null) {
                throw new Error('All `fn` arguments of methods(Class, ...fn) must be named functions!');
            }
            Object.defineProperty(Class.prototype, method.name, {
                enumerable : method.name[0] !== '_',
                value      : method
            });
        }
    }
    /**
     * End contents of {tools.js}
     */

    /**
     * Begin contents of {utils/EventEmitter.js}
     */
    var EventEmitter = (function() {
        function EventEmitter() {}
        /**
         * Absorbed from the Exoskeleton, reworked into a class!
         */
        methods(EventEmitter,
            /**
             * Bind an event to a `callback` function. Passing `"all"` will bind
             * the callback to all events fired.
             */
            function on(name, callback, context) {
                if (!eventsApi(this, 'on', name, [callback, context]) || !callback) return this;
                this._events || (this._events = {});
                var events = this._events[name] || (this._events[name] = []);
                events.push({ callback : callback, context : context, ctx : context || this });
                return this;
            },

            /**
             * Bind an event to only be triggered a single time. After the first time
             * the callback is invoked, it will be removed.
             */
            function once(name, callback, context) {
                if (!eventsApi(this, 'once', name, [callback, context]) || !callback) return this;
                var self = this;
                var ran;
                var once = function() {
                    if (ran) return;
                    ran = true;
                    self.off(name, once);
                    callback.apply(this, arguments);
                };
                once._callback = callback;
                return this.on(name, once, context);
            },

            /**
             * Remove one or many callbacks. If `context` is null, removes all
             * callbacks with that function. If `callback` is null, removes all
             * callbacks for the event. If `name` is null, removes all bound
             * callbacks for all events.
             */
            function off(name, callback, context) {
                var retain, ev, events, names, i, l, j, k;
                if (!this._events || !eventsApi(this, 'off', name, [callback, context])) return this;
                if (!name && !callback && !context) {
                    this._events = void 0;
                    return this;
                }
                names = name ? [name] : Object.keys(this._events);
                for (i = 0, l = names.length; i < l; i++) {
                    name = names[i];
                    if (events = this._events[name]) {
                        this._events[name] = retain = [];
                        if (callback || context) {
                            for (j = 0, k = events.length; j < k; j++) {
                                ev = events[j];
                                if ((callback && callback !== ev.callback && callback !== ev.callback._callback) ||
                                    (context && context !== ev.context)) {
                                    retain.push(ev);
                                }
                            }
                        }
                        if (!retain.length) delete this._events[name];
                    }
                }

                return this;
            },

            /**
             * Trigger one or many events, firing all bound callbacks. Callbacks are
             * passed the same arguments as `trigger` is, apart from the event name
             * (unless you're listening on `"all"`, which will cause your callback to
             * receive the true name of the event as the first argument).
             */
            function trigger(name) {
                if (!this._events) return this;
                var args = Array.prototype.slice.call(arguments, 1);
                if (!eventsApi(this, 'trigger', name, args)) return this;
                var events = this._events[name];
                var allEvents = this._events.all;
                if (events) triggerEvents(events, args);
                if (allEvents) triggerEvents(allEvents, arguments);
                return this;
            },

            /**
             * Tell this object to stop listening to either specific events ... or
             * to every object it's currently listening to.
             */
            function stopListening(obj, name, callback) {
                var listeningTo = this._listeningTo;
                if (!listeningTo) return this;
                var remove = !name && !callback;
                if (!callback && typeof name === 'object') callback = this;
                if (obj) (listeningTo = {})[obj._listenId] = obj;
                for (var id in listeningTo) {
                    obj = listeningTo[id];
                    obj.off(name, callback, this);
                    if (remove || !Object.keys(obj._events).length) delete this._listeningTo[id];
                }
                return this;
            }
        );

        // Regular expression used to split event strings.
        var eventSplitter = /\s+/;

        /**
         * Implement fancy features of the EventEmitter API such as multiple event
         * names `"change blur"` and jQuery-style event maps `{change: action}`
         * in terms of the existing API.
         */
        var eventsApi = function(obj, action, name, rest) {
            if (!name) return true;

            // Handle event maps.
            if (typeof name === 'object') {
                for (var key in name) {
                    obj[action].apply(obj, [key, name[key]].concat(rest));
                }
                return false;
            }

            // Handle space separated event names.
            if (eventSplitter.test(name)) {
                var names = name.split(eventSplitter);
                for (var i = 0, l = names.length; i < l; i++) {
                    obj[action].apply(obj, [names[i]].concat(rest));
                }
                return false;
            }

            return true;
        };

        /**
         * A difficult-to-believe, but optimized internal dispatch function for
         * triggering events. Tries to keep the usual cases speedy (most internal
         * Backbone events have 3 arguments).
         */
        var triggerEvents = function(events, args) {
            var ev, i = -1, l = events.length, a1 = args[0], a2 = args[1], a3 = args[2];
            switch (args.length) {
                case 0:
                    while (++i < l) (ev = events[i]).callback.call(ev.ctx);
                    return;
                case 1:
                    while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1);
                    return;
                case 2:
                    while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1, a2);
                    return;
                case 3:
                    while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1, a2, a3);
                    return;
                default:
                    while (++i < l) (ev = events[i]).callback.apply(ev.ctx, args);
                    return;
            }
        };

        var listenMethods = { listenTo : 'on', listenToOnce : 'once' };

        var listenId = 0;
        function getListenId() {
            listenId += 1;
            return 'l' + listenId;
        }

        // Inversion-of-control versions of `on` and `once`. Tell *this* object to
        // listen to an event in another object ... keeping track of what it's
        // listening to.
        Object.keys(listenMethods).forEach(function(method) {
            var implementation = listenMethods[method];
            EventEmitter.prototype[method] = function(obj, name, callback) {
                var listeningTo = this._listeningTo || (this._listeningTo = {});
                var id = obj._listenId || (obj._listenId = getListenId());
                listeningTo[id] = obj;
                if (!callback && typeof name === 'object') callback = this;
                obj[implementation](name, callback, this);
                return this;
            };
        });

        return EventEmitter;
    })();
    /**
     * End contents of {utils/EventEmitter.js}
     */

    /**
     * Begin contents of {utils/timer.js}
     */
    crayon.timer = (function() {
        var canvasStack = [],
            canvasCount = 0,
            time,
            timerid;

        function tick(timestamp) {
            var i;
            for (i = 0; i < canvasCount; i++) {
                canvasStack[i].render(timestamp);
            }
            this.trigger('frame', timestamp);
            timerid = window.requestAnimationFrame(this.tick);
        }

        function Timer() {
            this.tick = tick.bind(this);
            this.start();
        }

        extend(Timer, EventEmitter);
        methods(Timer,
            function now() {
                return performance.now();
            },

            function getSeconds() {
                return ~~(this.now() / 1000);
            },

            function bind(canvas) {
                canvasStack.push(canvas);
                canvasCount += 1;
            },

            function start() {
                time = this.now();
                timerid = window.requestAnimationFrame(this.tick);
            },

            function stop() {
                window.cancelAnimationFrame(timerid);
            }
        );

        return new Timer;
    })();
    /**
     * End contents of {utils/timer.js}
     */

    /**
     * Begin contents of {utils/Color.js}
     */
    var Color = crayon.Color = (function() {
        var rgbaPattern = /\s*rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d+.?\d*|\d*.?\d+)s*\)\s*/i;

        function Color(r, g, b, a) {
            this.__isColor = true;
            if (typeof r === 'string') {
                var hash, matches;
                if (r[0] === '#') {
                    hash = r;
                    if (hash.length === 7) {
                        r = parseInt(hash.slice(1, 3), 16);
                        g = parseInt(hash.slice(3, 5), 16);
                        b = parseInt(hash.slice(5, 7), 16);
                    } else if (hash.length === 4) {
                        r = parseInt(hash[1] + hash[1], 16);
                        g = parseInt(hash[2] + hash[2], 16);
                        b = parseInt(hash[3] + hash[3], 16);
                    } else {
                        throw new Error('Invalid color string: ' + hash);
                    }
                } else if (matches = r.match(rgbaPattern)) {
                    r = Number(matches[1]);
                    g = Number(matches[2]);
                    b = Number(matches[3]);
                    a = parseFloat(matches[4]);
                    if (Number.isNaN(a)) a = 1;
                } else {
                    throw new Error('Invalid color string: ' + r);
                }
            }
            this.set(r, g, b, a);
        }

        methods(Color,
            function set(r, g, b, a) {
                // Tilde is way more performant than Math.floor
                this.r = ~~r;
                this.g = ~~g;
                this.b = ~~b;
                this.a = (a != null) ? a : 1;
                this.cacheString();
            },

            function cacheString() {
                this.string = 'rgba(' + this.r + ',' + this.g + ',' + this.b + ',' + this.a + ')';
            },

            function toString() {
                return this.string;
            }
        );

        return Color;
    })();


    /**
     * End contents of {utils/Color.js}
     */

    /**
     * Begin contents of {utils/Point.js}
     */
    var Point = crayon.Point = (function() {
        function Point(x, y) {
            this.__isPoint = true;
            this.x = x;
            this.y = y;
        }

        extend(Point, EventEmitter);
        methods(Point,
            function move(x, y) {
                if (this.x === x && this.y === y) return;
                if (x != null) this.x = x;
                if (y != null) this.y = y;
                this.trigger('move', this);
            }
        );

        return Point;
    })();
    /**
     * End contents of {utils/Point.js}
     */

    /**
     * Begin contents of {utils/RelativePoint.js}
     */
    var RelativePoint = crayon.RelativePoint = (function () {
        /**
         * @param {number} relX
         * @param {number} relY
         * @param {Point} root
         * @constructor
         */
        function RelativePoint(relX, relY, root) {
            this.__isPoint = true;
            this.x = 0;
            this.y = 0;
            this.root = root;
            this.relX = (relX == null) ? 0 : relX;
            this.relY = (relY == null) ? 0 : relY;
            this.listenTo(root, 'move', this._update);
        }

        extend(RelativePoint, EventEmitter);
        methods(RelativePoint,
            function _update() {
                this.x = this.root.x + this.relX;
                this.y = this.root.y + this.relY;
                this.trigger('move');
            },

            function move(relX, relY) {
                if (relX != null) this.relX = relX;
                if (relY != null) this.relY = relY;
                this._update();
            }
        );

        return RelativePoint;
    })();
    /**
     * End contents of {utils/RelativePoint.js}
     */

    /**
     * Begin contents of {utils/MappedPoint.js}
     */
    var MappedPoint = crayon.MappedPoint = (function () {
        function noop(value) {
            return value;
        }

        /**
         * @param {function|null} mapX
         * @param {function|null} mapY
         * @param {Point} root
         * @constructor
         */
        function MappedPoint(mapX, mapY, root) {
            this.__isPoint = true;
            this.x = 0;
            this.y = 0;
            this.root = root;
            this.mapX = (mapX == null) ? noop : mapX;
            this.mapY = (mapY == null) ? noop : mapY;
            this.listenTo(root, 'move', this._update);
        }

        extend(MappedPoint, EventEmitter);
        methods(MappedPoint,
            function _update() {
                this.x = this.mapX(this.root.x);
                this.y = this.mapY(this.root.y);
                this.trigger('move');
            },

            function move(x, y) {
                this.root.move(x, y);
            }
        );

        return MappedPoint;
    })();
    /**
     * End contents of {utils/MappedPoint.js}
     */

    /**
     * Begin contents of {utils/Transformation.js}
     */
    var Transformation = (function() {
        function Transformation(options) {
            this.options = Object.assign({}, this.defaults, options);
            if (this.options.from == null) this.options.from = {};
            if (this.options.to == null) this.options.to = {};

            this.finished = false;
            this.startTime = crayon.timer.now() + this.options.delay;
            this.endTime = this.startTime + this.options.duration;
        }

        extend(Transformation, EventEmitter);
        defaults(Transformation, {
            duration   : 1000,
            delay      : 0,
            from       : null,
            to         : null,
            custom     : null,
            transition : 'linear'
        });

        var transitions = {
            linear    : function(stage) {
                return stage;
            },
            easeOut   : function(stage) {
                return Math.sin(stage * Math.PI / 2);
            },
            easeIn    : function(stage) {
                return 1 - Math.sin((1 - stage) * Math.PI / 2);
            },
            easeInOut : function(stage) {
                return (Math.sin((stage * 2 - 1) * Math.PI / 2) + 1) / 2;
            }
        };

        methods(Transformation,
            function isFinished() {
                return this.finished;
            },

            function getStage(time) {
                if (time <= this.startTime) return 0;
                if (time >= this.endTime) return 1;

                var stage      = (time - this.startTime) / this.options.duration,
                    transition = transitions[this.options.transition];

                if (typeof transition !== 'function') throw new Error('Unknown transition: ' + this.options.transition);

                return transition(stage);
            },

            function getValue(from, to, stage) {
                // Handle numbers
                if (typeof from === 'number') return (from * (1 - stage)) + (to * stage);

                // Handle colors
                if (from.__isColor) {
                    return new Color(
                        this.getValue(from.r, to.r, stage),
                        this.getValue(from.g, to.g, stage),
                        this.getValue(from.b, to.b, stage),
                        this.getValue(from.a, to.a, stage)
                    );
                }

                // Fallback
                return to;
            },

            function progress(element, time) {
                if (this.finished) return;
                if (time < this.startTime) return;

                var options = {},
                    stage   = this.getStage(time);

                if (typeof this.options.custom === 'function') this.options.custom.call(element, stage);

                var from = this.options.from,
                    to   = this.options.to,
                    option;

                for (option in to) {
                    options[option] = this.getValue(from[option], to[option], stage);
                }

                element.set(options);

                if (time >= this.endTime) {
                    this.destroy();
                    this.finished = true;
                    this.trigger('end');
                }
            },

            function destroy() {
                delete this.options.to;
                delete this.options.from;
            }
        );

        return Transformation;
    })();
    /**
     * End contents of {utils/Transformation.js}
     */

    /**
     * Begin contents of {utils/ImageAsset.js}
     */
    var ImageAsset = crayon.ImageAsset = (function () {
        function ImageAsset(url) {
            this.__isAsset = true;
            this.__isLoaded = false;
            this._width = 0;
            this._height = 0;

            var image = new Image;
            image.src = url;
            image.onload = (function() {
                var width = this._width = image.naturalWidth,
                    height = this._height = image.naturalHeight;

                this._cache = new Canvas({
                    width: width,
                    height: height,
                    'static': true
                });

                this._cache.drawRaw(image, 0, 0, width, height);
                this._image = this._cache.getDocumentElement();
                this.__isLoaded = true;
                this.trigger('loaded');

                // loaded happens only once
                this.off('loaded');
                delete image.onload;
            }).bind(this);
        }

        extend(ImageAsset, EventEmitter);
        methods(ImageAsset,
            function getPixelAlpha(x, y) {
                return this._cache.getPixelAlpha(x, y);
            },

            function getDocumentElement() {
                if (this.__isLoaded) return this._image;
                return null;
            }
        );

        return ImageAsset;
    })();
    /**
     * End contents of {utils/ImageAsset.js}
     */

    /**
     * Begin contents of {utils/assets.js}
     */
    crayon.assets = (function() {
        var store = {};

        return {
            get : function get(url) {
                if (store[url] != null) return store[url];
                return store[url] = new ImageAsset(url);
            },

            define : function define(url, dataurl) {
                return store[url] = new ImageAsset(dataurl);
            },

            preload : function preload(urls, callback) {
                if (typeof urls === 'string') urls = [urls];

                var count = urls.length;

                urls.forEach(function(url) {
                    var asset = this.get(url);
                    if (asset.__isLoaded) {
                        count -= 1;
                        if (count === 0 && callback != null) callback();
                    } else {
                        asset.on('loaded', function() {
                            count -= 1;
                            if (count === 0 && callback != null) callback();
                        });
                    }
                }, this);
            }
        }
    })();
    /**
     * End contents of {utils/assets.js}
     */

    /**
     * Begin contents of {utils/filters.js}
     */
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
    /**
     * End contents of {utils/filters.js}
     */

    /**
     * Begin contents of {elements/Element.js}
     */
    var Element = (function() {
        function Element(options) {
            this.__isElement = true;
            this.transformStack = [];
            this.transformCount = 0;
            this.changed = false;
            this.changedZ = false;
            this.changedAttributes = null;

            if (options.position == null) {
                options.position = new Point(options.x, options.y);
            }

            // Set the options using the defaults
            this.options = Object.assign({}, this.defaults, options);
            this.listenTo(this.options.position, 'move', this.change);

            // cache anchor position
            this.listenTo(this, 'change:anchorX change:anchorY change:anchorInPixels', this.calculateAnchor);

            // reset the `move` listeners when position Point changes
            this.listenTo(this, 'change:position', this.rebindPosition);
            this.calculateAnchor();
        }

        extend(Element, EventEmitter);
        defaults(Element, {
            position       : null,
            x              : 0,
            y              : 0,
            z              : 0,
            snap           : false,
            anchorX        : 0.5,
            anchorY        : 0.5,
            anchorInPixels : false,
            width          : 0,
            height         : 0,
            alpha          : 1.0,
            rotation       : 0.0,
            scaleX         : 1.0,
            scaleY         : 1.0,
            skewX          : 0,
            skewY          : 0,
            hidden         : false,
            input          : false,
            composition    : 'source-over'
        });
        methods(Element,
            function rebindPosition() {
                this.stopListening(null, 'move');
                this.listenTo(this.options.position, 'move', this.change);
            },

            function change() {
                this.changed = true;
            },

            function validateColor(value) {
                if (!value.__isColor) value = new Color(value);
                return value;
            },

            function calculateAnchor() {
                if (this._anchor == null) this._anchor = {};
                var anchor = this._anchor;
                if (this.options.anchorInPixels) {
                    anchor.x = this.options.anchorX;
                    anchor.y = this.options.anchorY;
                } else {
                    anchor.x = this.options.anchorX * this.options.width;
                    anchor.y = this.options.anchorY * this.options.height;
                }
                if (this.options.snap) {
                    anchor.x = Math.round(anchor.x);
                    anchor.y = Math.round(anchor.y);
                }
            },

            function getAnchor() {
                return this._anchor;
            },

            function hide() {
                if (this.options.hidden) return;
                this.options.hidden = true;
                this.changed = true;
            },

            function show() {
                if (!this.options.hidden) return;
                this.options.hidden = false;
                this.changed = true;
            },

            function isHidden() {
                return this.options.hidden;
            },

            function transform(options) {
                // Set starting values if not defined
                if (options.from == null) options.from = {};
                if (options.to == null) options.to = {};

                var option;
                for (option in options.to) {
                    if (options.from[option] === undefined) options.from[option] = this.options[option];
                }
                for (option in options.from) {
                    if (options.to[option] === undefined) options.to[option] = this.options[option];
                }
                this.validate(options.from);
                this.validate(options.to);
                var transform = new Transformation(options);
                this.transformStack.push(transform);
                this.transformCount += 1;
                return transform;
            },

            function stop() {
                if (this.transformCount === 0) return;

                this.tranformStack.forEach(function(transform) {
                    transform.destroy();
                });

                this.transformStack = [];
                this.transformCount = 0;
            },

            /**
             * Used to progress current transformation stack
             *
             * @param {Number} frameTime
             */
            function progress(frameTime) {
                if (this.transformCount === 0) return;

                var remove = false;
                this.transformStack.forEach(function(transform) {
                    transform.progress(this, frameTime);
                    if (transform.isFinished()) remove = true;
                }, this);

                // only recreate the array if necessary, boolean is cheap
                if (remove) {
                    this.transformStack = this.transformStack.filter(function(transform) {
                        return !transform.isFinished();
                    });
                    this.transformCount = this.transformStack.length;
                }
            },

            /**
             * Used to set alpha, position, scale and rotation on the canvas prior to rendering.
             */
            function prepare(canvas) {
                var ctx     = canvas.ctx,
                    options = this.options,
                    x       = options.position.x,
                    y       = options.position.y;

                if (options.snap) {
                    x = Math.round(x);
                    y = Math.round(y);
                }
                ctx.setTransform(options.scaleX, options.skewX, options.skewY, options.scaleY, x, y);
                if (options.alpha !== 1) ctx.globalAlpha = options.alpha;
                if (options.rotation !== 0) ctx.rotate(options.rotation);
                if (options.composition !== 'source-over') ctx.globalCompositeOperation = options.composition;
            },

            function render(canvas) {
            },

            function pointOnElement(x, y) {
                var anchor  = this.getAnchor(),
                    options = this.options;

                x = x - options.position.x;
                y = y - options.position.y;

                if (options.scaleX !== 1) x = x / options.scaleX;
                if (options.scaleY !== 1) y = y / options.scaleY;
                if (options.rotation !== 0) {
                    var cos   = Math.cos(-options.rotation),
                        sin   = Math.sin(-options.rotation),
                        tempX = cos * x - sin * y;

                    y = sin * x + cos * y;
                    x = tempX;
                }
                return (
                    (x > -anchor.x && x <= options.width - anchor.x) &&
                    (y > -anchor.y && y <= options.height - anchor.y)
                );
            },

            function delegateInputEvent(type, x, y) {
                var options = this.options;
                if (
                    (options.input === false) ||
                    (options.hidden === true) ||
                    (options.alpha === 0) ||
                    (options.scaleX === 0 || options.scaleY === 0) ||
                    (!this.pointOnElement(x, y))
                ) return false;

                this.trigger(type);
                return true;
            },

            function set(options, value) {
                if (typeof options === 'string') {
                    this.options[options] = value;
                    this.changed = true;
                    this.changedZ = this.changedZ || options === 'z';
                } else {
                    var option;
                    for (option in options) {
                        this.options[option] = options[option];
                    }
                    this.changed = true;
                    this.changedZ = this.changedZ || options.z != null;
                }

                return this;
            },

            function get(option) {
                return this.options[option];
            }
        );

        return Element;
    })();
    /**
     * End contents of {elements/Element.js}
     */

    /**
     * Begin contents of {elements/Sprite.js}
     */
    var Sprite = crayon.Sprite = (function() {
        function Sprite(options) {
            if (typeof options.src === 'string') {
                var asset = options.src = crayon.assets.get(options.src);

                if (!asset.__isLoaded) {
                    asset.once('loaded', function() {
                        this.change();
                        this.calculateFrames();
                        this.calculateAnchor();
                    }, this);
                } else {
                    this.calculateFrames();
                }
            }

            Element.call(this, options);

            this.buffer = null;
            this._useBuffer = false;
            this._animated = false;
            this._animations = {};
            this._fallbackAnimation = 'idle';
            this._frameDuration = 0;
            this._framesModulo = 0;
        }

        extend(Sprite, Element);
        defaults(Sprite, {
            src   : null,
            cropX : 0,
            cropY : 0
        });
        methods(Sprite,
            function calculateFrames() {
                var src = this.options.src;
                if (this.options.width === 0) this.options.width = src._width;
                if (this.options.height === 0) this.options.height = src._height;
                this._framesModulo = ~~(src._width / this.options.width);
            },

            function render(canvas) {
                var anchor = this.getAnchor();

                if (this._useBuffer) {
                    canvas.drawAsset(this.buffer, -anchor.x, -anchor.y, this.options.width, this.options.height)
                } else {
                    canvas.drawAsset(
                        this.options.src,
                        -anchor.x,
                        -anchor.y,
                        this.options.width,
                        this.options.height,
                        this.options.cropX,
                        this.options.cropY
                    )
                }
            },

            function pointOnElement(x, y) {
                var anchor = this.getAnchor();
                var options = this.options;

                x = x - options.position.x;
                y = y - options.position.y;

                if (options.scaleX !== 1) x = x / options.scaleX;
                if (options.scaleY !== 1) y = y / options.scaleY;

                if (options.rotation !== 0) {
                    var cos  = Math.cos(-options.rotation),
                        sin  = Math.sin(-options.rotation),
                        newX = cos * x - sin * y;

                    y = sin * x + cos * y;
                    x = newX;
                }

                x += anchor.x;
                y += anchor.y;

                if (x <= 0 || x > options.width) return false;
                if (y <= 0 || y > options.height) return false;

                x = Math.round(x + options.cropX);
                y = Math.round(y + options.cropY);

                return options.src.getPixelAlpha(x, y) !== 0;
            },

            function addAnimation(label, fps, frames) {
                if (fps <= 0) fps = 1;

                this._animations[label] = {
                    frames        : frames,
                    frameDuration : 1000 / fps
                };

                return this;
            },

            function animate(label, looping) {
                var animation;
                if (label == null) label = this._fallbackAnimation;
                if (looping == null) looping = false;

                animation = this._animations[label];
                if (!animation) return;
                if (looping) this._fallbackAnimation = label;

                this._frames = animation.frames;
                this._frameDuration = animation.frameDuration;
                this._currentIndex = -1;
                this._animationStart = crayon.timer.now();
                this._animationEnd = this._animationStart + this._frames.length * this._frameDuration;
                this._animated = true;
            },

            function progress(frameTime) {
                var index;
                if (this._animated && this._framesModulo) {
                    if (frameTime >= this._animationEnd) return this.animate();
                    index = ~~((frameTime - this._animationStart) / this._frameDuration);
                    if (index !== this._currentIndex) {
                        this._currentIndex = index;
                        this.setFrame(this._frames[index]);
                    }
                }

                // Progress transformations *AFTER* frame has been set
                Element.prototype.progress.call(this, frameTime);
            },

            function setFrame(frame) {
                this._useBuffer = false;

                var frameX = frame % this._framesModulo,
                    frameY = ~~(frame / this._framesModulo);

                this.options.cropX = frameX * this.options.width;
                this.options.cropY = frameY * this.options.height;

                this.change();
            },

            function freeze() {
                this._animated = false;
            },

            function _drawSourceOnBuffer() {
                this.buffer.drawAsset(
                    this.options.src,
                    0,
                    0,
                    this.options.width,
                    this.options.height,
                    this.options.cropX,
                    this.options.cropY
                );
            },

            function createBuffer() {
                if (this.buffer == null) {
                    this.buffer = new Canvas({
                        'width'  : this.options.width,
                        'height' : this.options.height,
                        'static' : true
                    });
                } else {
                    this.buffer.clear();
                }
                this._drawSourceOnBuffer();
            },

            function filter(filter) {
                var fn = crayon.filters[filter];
                if (typeof fn !== 'function') return;

                this.createBuffer();
                this._useBuffer = true;

                var args = [], len = arguments.length, i;
                for (i = 1; i < len; i++) {
                    args.push(arguments[i]);
                }

                fn.apply(this.buffer, args);
                this.change();
            },

            function clearFilters() {
                if (this.buffer == null) return;
                this.buffer.clear();
                this._drawSourceOnBuffer();
            },

            function removeFilter() {
                this.buffer = null;
                this._useBuffer = false;
                this.change();
            }
        );

        return Sprite;
    })();
    /**
     * End contents of {elements/Sprite.js}
     */

    /**
     * Begin contents of {elements/Shape.js}
     */
    var Shape = crayon.Shape = (function() {
        function Shape(options) {
            Element.call(this, options);
        }

        extend(Shape, Element);
        defaults(Shape, {
            stroke      : 0,
            strokeColor : '#000',
            lineCap     : 'butt', // butt|round|square
            lineJoin    : 'miter', // miter|bevel|round
            erase       : false,
            fill        : true,
            color       : '#000',
            shadow      : false,
            shadowX     : 0,
            shadowY     : 0,
            shadowBlur  : 0,
            shadowColor : '#000'
        });
        methods(Shape,
            function validate(options) {
                Element.prototype.validate.call(this, options);
                if (options.color !== undefined) options.color = this.validateColor(options.color);
                if (options.strokeColor !== undefined) options.strokeColor = this.validateColor(options.strokeColor);
                if (options.shadowColor !== undefined) options.shadowColor = this.validateColor(options.shadowColor);
            },

            function drawPath(canvas) {
            },

            function render(canvas) {
                if (this.options.shadow) {
                    canvas.setShadow(
                        this.options.shadowX,
                        this.options.shadowY,
                        this.options.shadowBlur,
                        this.options.shadowColor
                    );
                }

                var ctx = canvas.ctx;
                ctx.beginPath();

                // Set line properties
                ctx.lineCap = this.options.lineCap;
                ctx.lineJoin = this.options.lineJoin;

                // Draw path
                this.drawPath(canvas);

                // Erase background before drawing?
                if (this.options.erase) {
                    ctx.save();
                    ctx.globalCompositeOperation = 'destination-out';
                    ctx.globalAlpha = 1.0;
                    canvas.fill('//000000');
                    ctx.restore();
                }

                // Fill and stroke if applicable
                if (this.options.fill) canvas.fill(this.options.color);
                if (this.options.stroke > 0) canvas.stroke(this.options.stroke, this.options.strokeColor);

                // ctx.closePath()
            }
        );

        return Shape;
    })();
    /**
     * End contents of {elements/Shape.js}
     */

    /**
     * Begin contents of {elements/Text.js}
     */
    var Text = crayon.Text = (function() {
        function Text(options) {
            Shape.call(this, options);
        }

        extend(Text, Shape);
        defaults(Text, {
            label    : 'crayon',
            align    : 'center', // left|right|center
            baseline : 'middle', // top|hanging|middle|alphabetic|ideographic|bottom
            italic   : false,
            bold     : false,
            size     : 12,
            font     : 'sans-serif'
        });
        methods(Text,
            function render(canvas) {
                if (this.options.shadow) {
                    canvas.setShadow(
                        this.options.shadowX,
                        this.options.shadowY,
                        this.options.shadowBlur,
                        this.options.shadowColor
                    );
                }

                if (this.options.fill) canvas.ctx.fillStyle = this.options.color.toString();
                canvas.ctx.textAlign = this.options.align;
                canvas.ctx.textBaseline = this.options.baseline;

                var font = [];
                if (this.options.italic) font.push('italic');
                if (this.options.bold) font.push('bold');
                font.push(this.options.size + 'px');
                font.push(this.options.font);

                canvas.ctx.font = font.join(' ');

                if (this.options.fill) canvas.ctx.fillText(this.options.label, 0, 0);

                if (this.options.stroke) {
                    canvas.ctx.lineWidth = this.options.stroke;
                    canvas.ctx.strokeStyle = this.options.strokeColor.toString();
                    canvas.ctx.strokeText(this.options.label, 0, 0);
                }
            }
        );

        return Text;
    })();
    /**
     * End contents of {elements/Text.js}
     */

    /**
     * Begin contents of {elements/Rectangle.js}
     */
    var Rectangle = crayon.Rectangle = (function() {
        function Rectangle(options) {
            Shape.call(this, options);
        }

        extend(Rectangle, Shape);
        defaults(Rectangle, {
            cornerRadius : 0 // radius of rounded corners
        });
        methods(Rectangle,
            function drawPath(canvas) {
                var anchor = this.getAnchor(),
                    ctx    = canvas.ctx;

                if (this.options.cornerRadius === 0) {
                    ctx.rect(-anchor.x, -anchor.y, this.options.width, this.options.height);
                    return;
                }

                var x = -anchor.x,
                    y = -anchor.y,
                    w = this.options.width,
                    h = this.options.height,
                    r = this.options.cornerRadius;

                ctx.moveTo(x + w - r, y);
                ctx.quadraticCurveTo(x + w, y, x + w, y + r);
                ctx.lineTo(x + w, y + h - r);
                ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
                ctx.lineTo(x + r, y + h);
                ctx.quadraticCurveTo(x, y + h, x, y + h - r);
                ctx.lineTo(x, y + r);
                ctx.quadraticCurveTo(x, y, x + r, y);
                ctx.closePath();
            }
        );

        return Rectangle;
    })();
    /**
     * End contents of {elements/Rectangle.js}
     */

    /**
     * Begin contents of {elements/Circle.js}
     */
    var Circle = crayon.Circle = (function() {
        function Circle(options) {
            Shape.call(this, options);

            this.options.width = this.options.radius * 2;
            this.options.height = this.options.radius * 2;
        }

        extend(Circle, Shape);
        defaults(Circle, {
            radius : 0, // radius of the circle
            angle  : Math.PI * 2
        });
        methods(Circle,
            function drawPath(canvas) {
                var ctx = canvas.ctx;
                ctx.arc(0, 0, this.options.radius, 0, this.options.angle, false);
                if (this.options.angle !== Math.PI * 2) ctx.lineTo(0, 0);
                ctx.closePath();
            },

            function pointOnElement(x, y) {
                // TODO: use anchor
                // var anchor = this.getAnchor();
                var options = this.options;

                if (options.angle === 0) return false;

                x = x - options.position.x;
                y = y - options.position.y;
                if (options.scaleX !== 1) x = x / options.scaleX;
                if (options.scaleY !== 1) y = y / options.scaleY;
                if (options.rotation !== 0) {
                    var cos   = Math.cos(-options.rotation),
                        sin   = Math.sin(-options.rotation),
                        tempX = cos * x - sin * y;

                    y = sin * x + cos * y;
                    x = tempX;
                }

                return (
                    (Math.sqrt(x * x + y * y) <= options.radius) &&
                    (Math.atan2(x, y) + Math.PI <= options.angle)
                );
            }
        );

        return Circle;
    })();
    /**
     * End contents of {elements/Circle.js}
     */

    /**
     * Begin contents of {elements/Ellipse.js}
     */
    var Ellipse = crayon.Rectangle = (function() {
        function Ellipse(options) {
            Shape.call(this, options);
        }

        extend(Ellipse, Shape);
        methods(Ellipse,
            function drawPath(canvas) {
                var anchor = this.getAnchor(),
                    ctx    = canvas.ctx,
                    x      = -anchor.x,
                    y      = -anchor.y,
                    w      = this.options.width,
                    h      = this.options.height,
                    magic  = 0.551784,
                    ox     = (w / 2) * magic, // control point offset horizontal
                    oy     = (h / 2) * magic, // control point offset vertical
                    xe     = x + w,           // x-end
                    ye     = y + h,           // y-end
                    xm     = x + w / 2,       // x-middle
                    ym     = y + h / 2;       // y-middle

                ctx.moveTo(x, ym);
                ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
                ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
                ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
                ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
                ctx.closePath();
            }
        );

        return Ellipse;
    })();
    /**
     * End contents of {elements/Ellipse.js}
     */

    /**
     * Begin contents of {elements/CustomShape.js}
     */
    var CustomShape = crayon.CustomShape = (function() {
        function CustomShape(options) {
            Shape.call(this, options);
            this.path = [];
            this.options.anchorInPixels = true;
        }

        extend(CustomShape, Shape);
        defaults(CustomShape, {
            anchorX : 0,
            anchorY : 0
        });
        methods(CustomShape,
            function _point(x, y) {
                var point;
                if (x.__isPoint && y == null) {
                    point = x;
                } else {
                    point = new Point(x, y);
                }
                this.listenTo(point, 'move', this.change);
                return point;
            },

            function drawPath(canvas) {
                var anchor = this.getAnchor(),
                    ctx    = canvas.ctx;

                ctx.moveTo(-anchor.x, -anchor.y);

                var len = this.path.length, i, fragment;
                for (i = 0; i < len; i++) {
                    fragment = this.path[i];
                    if (fragment == null) {
                        ctx.closePath();
                    } else {
                        var method = fragment[0],
                            point  = fragment[1];

                        ctx[method](point.x - anchor.x, point.y - anchor.y);
                    }
                }
            },

            function lineTo(x, y) {
                this.path.push(['lineTo', this._point(x, y)]);

                return this;
            },

            function moveTo(x, y) {
                this.path.push(['moveTo', this._point(x, y)]);

                return this;
            },

            function close() {
                this.path.push(null);

                return this;
            },

            function _castRay(pointA, pointB, rayY) {
                // horizontal line matching the ray? Return left-most point
                if (pointA.y === pointB.y === rayY) return Math.min(pointA.x, pointB.x);

                // line not crossing ray? Ignore
                if (pointA.y > rayY && pointB.y > rayY) return null;
                if (pointA.y < rayY && pointB.y < rayY) return null;

                // find intersection
                return ((rayY - pointA.y) / (pointB.y - pointA.y)) * (pointB.x - pointA.x) + pointA.x;
            },

            function pointOnElement(x, y) {
                // TODO: use anchor
                // var anchor = this.getAnchor();
                var options = this.options;

                x = x - options.position.x;
                y = y - options.position.y;

                if (options.scaleX !== 1) x = x / options.scaleX;
                if (options.scaleY !== 1) y = y / options.scaleY;
                if (options.rotation !== 0) {
                    var cos   = Math.cos(-options.rotation),
                        sin   = Math.sin(-options.rotation),
                        tempX = cos * x - sin * y;

                    y = sin * x + cos * y;
                    x = tempX;
                }
                var pointA     = new Point(0, 0),
                    startPoint = pointA,
                    count      = 0,
                    pointB, rayX;

                // iterate through all lines of the polygon
                var len = this.path.length, i, fragment;
                for (i = 0; i < len; i++) {
                    fragment = this.path[i];

                    if (fragment === null) {
                        // ending line? Go back to starting point
                        pointB = startPoint;
                    } else if (fragment[0] === 'moveTo' && pointA === startPoint) {
                        // moving without drawing?
                        pointA = startPoint = fragment[1];
                        continue;
                    } else {
                        // normal line? Grab the new ending point
                        pointB = fragment[1];
                    }
                    rayX = this._castRay(pointA, pointB, y);

                    // increase the count if the line is on the left side
                    if (rayX !== null && rayX <= x) count += 1;

                    // set starting point for the next line
                    pointA = pointB;
                }
                return !!(count % 2);
            }
        );

        return CustomShape;
    })();
    /**
     * End contents of {elements/CustomShape.js}
     */

    /**
     * Begin contents of {Canvas.js}
     */
    var Canvas = crayon.Canvas = (function() {
        function Canvas(options) {
            this.__isAsset = true;
            this.__isLoaded = true;
            this.changed = false;
            this.unordered = false;
            this.elements = [];

            // Set the options using the defaults
            this.options = Object.assign({}, this.defaults, options);

            if (this.options.id != null) {
                this._canvas = document.getElementById(this.options.id);
                this._width = this.options.width = Number(this._canvas.width);
                this._height = this.options.height = Number(this._canvas.height);
            } else {
                this._canvas = document.createElement('canvas');
                this._canvas.setAttribute('width', this.options.width);
                this._canvas.setAttribute('height', this.options.height);
                this._width = this.options.width;
                this._height = this.options.height;
            }

            this.ctx = this._canvas.getContext('2d');
            this.ctx.save();

            if (!this.options['static']) {
                this._hoverElement = null;
                this._bindInputEvents();
                crayon.timer.bind(this);
            }
        }

        extend(Canvas, EventEmitter);
        defaults(Canvas, {
            id: null,
            width: 0,
            height: 0,
            'static': false
        });
        methods(Canvas,
            function _bindInputEvents() {
                // bind touch events
                ['touchstart', 'touched'].forEach(function(event) {
                    this._canvas.addEventListener(event, this.delegateInputEvent.bind(this, event, false, true), true);
                }, this);

                // bind mouse events
                ['mousedown', 'mouseup', 'click', 'mousemove'].forEach(function(event) {
                    this._canvas.addEventListener(event, this.delegateInputEvent.bind(this, event), true);
                }, this);
                this._canvas.onmouseleave = this.handleMouseLeave.bind(this);
            },

            function delegateInputEvent(type, hover, touch, e) {
                if (arguments.length === 2) e = hover;
                var te, x, y;
                if (touch) {
                    te = e.touches[0] || e.changedTouches[0];
                    x = te.pageX - this._canvas.offsetTop;
                    y = te.pageY - this._canvas.offsetLeft;
                } else {
                    x = e.layerX;
                    y = e.layerY;
                }
                e.preventDefault();

                var elements = this.elements,
                    index    = elements.length,
                    element;

                // fastest iteration from top to bottom
                while (index--) {
                    element = elements[index];
                    if (element.delegateInputEvent(type, x, y)) {
                        if (hover) {
                            if (element === this._hoverElement) return;
                            if (this._hoverElement !== null) this._hoverElement.trigger('mouseleave');
                            this._hoverElement = element;
                            element.trigger('mouseenter');
                        }
                        return;
                    }
                }

                this.trigger(type);
                if (hover) this.handleMouseLeave();
            },

            function handleMouseLeave() {
                if (this._hoverElement !== null) {
                    this._hoverElement.trigger('mouseleave');
                    this._hoverElement = null;
                }
            },

            function getDocumentElement() {
                return this._canvas;
            },

            function fill(color) {
                this.ctx.fillStyle = color.toString();
                this.ctx.fill();
            },

            function stroke(width, color) {
                this.ctx.lineWidth = width;
                this.ctx.strokeStyle = color.toString();
                this.ctx.stroke();
            },

            function setShadow(x, y, blur, color) {
                if (x == null) x = 0;
                if (y == null) y = 0;
                if (blur == null) blur = 0;
                if (color == null) color = '#000000';

                this.ctx.shadowOffsetX = x;
                this.ctx.shadowOffsetY = y;
                this.ctx.shadowBlur = blur;
                this.ctx.shadowColor = color.toString();
            },

            function add() {
                var i, len = arguments.length, element;
                for (i = 0; i < len; i++) {
                    element = arguments[i];
                    if (!element.__isElement) throw new Error('Tried to add a non-Element to Canvas');
                    this.elements.push(element);
                }
            },

            function remove(elementToRemove) {
                this.elements = this.elements.filter(function(element) {
                    return element !== elementToRemove;
                });
            },

            function wipe() {
                this.elements.forEach(function(element) {
                    element.stopListening();
                });
                this.elements = [];
                this.changed = true;
            },

            function reorder() {
                this.elements.sort(function(a, b) {
                    return a.get('z') - b.get('z');
                });
            },

            function clear() {
                this.ctx.clearRect(0, 0, this.options.width, this.options.height);
            },

            function render(frameTime) {
                var element, i, len = this.elements.length;
                var changed = this.changed;
                var changedZ = false;
                for (i = 0; i < len; i++) {
                    element = this.elements[i];
                    element.progress(frameTime);
                    changed = changed || element.changed;
                    changedZ = changed || element.changedZ;
                }

                if (!changed) return;
                if (changedZ) this.reorder();

                this.clear();
                for (i = 0; i < len; i++) {
                    element = this.elements[i];
                    if (element.isHidden()) continue;

                    this.ctx.save();
                    element.prepare(this);
                    element.render(this);
                    element.changed = false;
                    this.ctx.restore();
                }

                this.changed = false;
            },

            function drawRaw(element, x, y, width, height, cropX, cropY) {
                if (cropX == null) cropX = 0;
                if (cropY == null) cropY = 0;

                return this.ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height);
            },

            function drawAsset(asset, x, y, width, height, cropX, cropY) {
                if (!asset || !asset.__isAsset) return;

                var element = asset.getDocumentElement();
                if (element == null) return;

                if (cropX == null) cropX = 0;
                if (cropY == null) cropY = 0;

                this.ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height);
            },

            function filter(filter) {
                var fn = crayon.filters[filter];
                if (typeof filter !== 'function') return;

                fn.apply(this, Array.prototype.slice.call(arguments, 1));
            },

            function getPixel(x, y) {
                return this.ctx.getImageData(x, y, 1, 1).data;
            },

            function getPixelAlpha(x, y) {
                return this.getPixel(x, y)[3];
            },

            function rgbaFilter(filter) {
                var imageData = this.ctx.getImageData(0, 0, this.options.width, this.options.height),
                    pixels    = imageData.data,
                    i         = 0,
                    l         = pixels.length,
                    rgba      = new Array(4);

                while (i < l) {
                    rgba[0] = pixels[i];
                    rgba[1] = pixels[i + 1];
                    rgba[2] = pixels[i + 2];
                    rgba[3] = pixels[i + 3];
                    filter(rgba);
                    pixels[i] = rgba[0];
                    pixels[i + 1] = rgba[1];
                    pixels[i + 2] = rgba[2];
                    pixels[i + 3] = rgba[3];
                    i += 4;
                }

                this.ctx.putImageData(imageData, 0, 0);
            }
        );

        return Canvas;
    })();
    /**
     * End contents of {Canvas.js}
     */


    if (typeof define === 'function' && define.amd) {
        define(function() {
            return crayon
        });
    } else if (typeof exports !== 'undefined') {
        module.exports = crayon;
    } else {
        this.crayon = crayon;
    }
}).call(window);