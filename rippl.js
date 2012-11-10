// Generated by CoffeeScript 1.4.0

/*
(c) 2012 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
*/


(function() {
  var Canvas, Circle, Color, CustomShape, Element, Ellipse, ImageAsset, ObjectAbstract, Rectangle, Shape, Sprite, Text, Timer, Transformation, rippl, vendor, vendors, _i, _len,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.rippl = rippl = {};

  rippl.ObjectAbstract = ObjectAbstract = (function() {

    function ObjectAbstract() {}

    ObjectAbstract.prototype.options = {};

    ObjectAbstract.prototype._validEventName = function(event) {
      if (typeof event !== 'string') {
        return false;
      }
      return true;
    };

    ObjectAbstract.prototype._validCallback = function(callback) {
      if (typeof callback !== 'function') {
        return false;
      }
      return true;
    };

    ObjectAbstract.prototype.on = function(event, callback) {
      var handlers;
      if (!this._validEventName(event)) {
        return;
      }
      if (!this._validCallback(callback)) {
        return;
      }
      handlers = this._eventHandlers || (this._eventHandlers = {});
      if (handlers[event] === void 0) {
        handlers[event] = [];
      }
      return handlers[event].push(callback);
    };

    ObjectAbstract.prototype.off = function(event, callbackToRemove) {
      var callback, handlers, stack, _i, _len, _ref;
      if (!(handlers = this._eventHandlers)) {
        return;
      }
      if (!this._validEventName(event)) {
        return this._eventHandlers = {};
      } else if (!this._validCallback(callbackToRemove)) {
        if (handlers[event] === void 0) {
          return;
        }
        return delete handlers[event];
      } else {
        if (handlers[event] === void 0) {
          return;
        }
        stack = [];
        _ref = handlers[event];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callback = _ref[_i];
          if (callback !== callbackToRemove) {
            stack.push(callback);
          }
        }
        return handlers[event] = stack;
      }
    };

    ObjectAbstract.prototype.trigger = function() {
      var args, callback, event, handlers, _i, _len, _ref;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if (!(handlers = this._eventHandlers)) {
        return;
      }
      if (!this._validEventName(event)) {
        return;
      }
      if (handlers[event] === void 0) {
        return false;
      }
      _ref = handlers[event];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        callback.apply(this, args);
      }
      return true;
    };

    ObjectAbstract.prototype.addDefaults = function(defaults) {
      var option;
      if (this.options !== void 0) {
        for (option in this.options) {
          if (defaults[option] === void 0) {
            defaults[option] = this.options[option];
          }
        }
      }
      return this.options = defaults;
    };

    ObjectAbstract.prototype.setOptions = function(options) {
      var defaults, option;
      if (options !== void 0) {
        defaults = this.options;
        this.options = {};
        for (option in defaults) {
          if (options[option] !== void 0) {
            this.options[option] = options[option];
          } else {
            this.options[option] = defaults[option];
          }
        }
        return true;
      }
      return false;
    };

    return ObjectAbstract;

  })();

  if (Date.now === void 0) {
    Date.now = (function() {
      return (new this).getTime();
    });
  }

  if (window.requestAnimationFrame === void 0) {
    vendors = ['ms', 'moz', 'webkit', 'o'];
    for (_i = 0, _len = vendors.length; _i < _len; _i++) {
      vendor = vendors[_i];
      if (window[vendor + 'RequestAnimationFrame']) {
        window.requestAnimationFrame = window[vendor + 'RequestAnimationFrame'];
        window.cancelAnimationFrame = window[vendor + 'CancelAnimationFrame'] || window[vendor + 'CancelRequestAnimationFrame'];
      }
    }
  }

  rippl.Timer = Timer = (function(_super) {

    __extends(Timer, _super);

    Timer.prototype.options = {
      fps: 60,
      autoStart: true
    };

    Timer.prototype._useAnimatinFrame = false;

    Timer.prototype.frameDuration = 0;

    function Timer(options) {
      this.setOptions(options);
      this.frameDuration = 1000 / this.options.fps;
      this.canvas = [];
      if (this.options.autoStart) {
        this.start();
      }
    }

    Timer.prototype.setFps = function(fps) {
      this.options.fps = fps;
      return this.frameDuration = 1000 / this.options.fps;
    };

    Timer.prototype.bind = function(canvas) {
      return this.canvas.push(canvas);
    };

    Timer.prototype.start = function() {
      var _this = this;
      this.time = Date.now();
      if (this._useAnimatinFrame) {
        return this.timerid = window.requestAnimationFrame(function(time) {
          return _this.tick(time);
        });
      } else {
        return this.timerid = setTimeout(function() {
          return _this.tickLegacy();
        }, this.frameDuration);
      }
    };

    Timer.prototype.stop = function() {
      if (this._useAnimatinFrame) {
        return window.cancelAnimationFrame(this.timerid);
      } else {
        return window.clearTimeout(this.timerid);
      }
    };

    Timer.prototype.getSeconds = function() {
      return ~~(Date.now() / 1000);
    };

    Timer.prototype.tick = function(frameTime) {
      var canvas, _j, _len1, _ref,
        _this = this;
      if (!frameTime) {
        frameTime = Date.now;
      }
      this.trigger('frame', frameTime);
      _ref = this.canvas;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        canvas = _ref[_j];
        canvas.render(frameTime);
      }
      return this.timerid = window.requestAnimationFrame(function(time) {
        return _this.tick(time);
      });
    };

    Timer.prototype.tickLegacy = function() {
      var canvas, delay, frameTime, postRenderTime, _j, _len1, _ref,
        _this = this;
      frameTime = Date.now();
      this.time += this.frameDuration;
      this.trigger('frame', frameTime);
      _ref = this.canvas;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        canvas = _ref[_j];
        canvas.render(frameTime);
      }
      postRenderTime = Date.now();
      delay = this.time - postRenderTime;
      if (delay < 0) {
        delay = 0;
        this.time = postRenderTime;
      }
      return this.timerid = window.setTimeout(function() {
        return _this.tickLegacy();
      }, delay);
    };

    return Timer;

  })(ObjectAbstract);

  rippl.Color = Color = (function() {

    Color.prototype.r = 255;

    Color.prototype.g = 255;

    Color.prototype.b = 255;

    Color.prototype.a = 1;

    Color.prototype.__isColor = true;

    Color.prototype.string = 'rgba(255,255,255,1)';

    Color.prototype.rgbaPattern = new RegExp('\\s*rgba\\(\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([\.0-9]+)\s*\\)\\s*', 'i');

    function Color(r, g, b, a) {
      var hash, l, matches;
      if (typeof r === 'string') {
        if (r[0] === '#') {
          hash = r;
          l = hash.length;
          if (l === 7) {
            r = parseInt(hash.slice(1, 3), 16);
            g = parseInt(hash.slice(3, 5), 16);
            b = parseInt(hash.slice(5, 7), 16);
          } else if (l === 4) {
            r = parseInt(hash[1] + hash[1], 16);
            g = parseInt(hash[2] + hash[2], 16);
            b = parseInt(hash[3] + hash[3], 16);
          } else {
            throw "Invalid color string: " + hash;
          }
        } else if (matches = r.match(this.rgbaPattern)) {
          r = Number(matches[1]);
          g = Number(matches[2]);
          b = Number(matches[3]);
          a = Number(matches[4]);
        } else {
          throw "Invalid color string: " + hash;
        }
      }
      this.set(r, g, b, a);
    }

    Color.prototype.set = function(r, g, b, a) {
      this.r = ~~r;
      this.g = ~~g;
      this.b = ~~b;
      if (a !== void 0) {
        this.a = a;
      }
      return this.cacheString();
    };

    Color.prototype.cacheString = function() {
      return this.string = "rgba(" + this.r + "," + this.g + "," + this.b + "," + this.a + ")";
    };

    Color.prototype.toString = function() {
      return this.string;
    };

    return Color;

  })();

  Transformation = (function(_super) {

    __extends(Transformation, _super);

    Transformation.prototype.startTime = 0;

    Transformation.prototype.finished = false;

    Transformation.prototype.options = {
      duration: 1000,
      delay: 0,
      from: null,
      to: null,
      transition: 'linear'
    };

    Transformation.prototype.transitions = {
      linear: function(stage) {
        return stage;
      },
      easeOut: function(stage) {
        return Math.sin(stage * Math.PI / 2);
      },
      easeIn: function(stage) {
        return 1 - Math.sin((1 - stage) * Math.PI / 2);
      },
      easeInOut: function(stage) {
        stage = stage * 2 - 1;
        return (Math.sin(stage * Math.PI / 2) + 1) / 2;
      }
    };

    Transformation.prototype.parseColors = function(value) {
      if (typeof value === 'string' && value[0] === '#') {
        return new Color(value);
      }
      return value;
    };

    function Transformation(options) {
      var option, value, _ref, _ref1;
      this.setOptions(options);
      if (this.options.from === null) {
        this.options.from = {};
      }
      if (this.options.to === null) {
        this.options.to = {};
      }
      this.startTime = Date.now() + this.options.delay;
      this.endTime = this.startTime + this.options.duration;
      this;

      _ref = this.options.from;
      for (option in _ref) {
        value = _ref[option];
        this.options.from[option] = this.parseColors(value);
      }
      _ref1 = this.options.to;
      for (option in _ref1) {
        value = _ref1[option];
        this.options.to[option] = this.parseColors(value);
      }
    }

    Transformation.prototype.isFinished = function() {
      return this.finished;
    };

    Transformation.prototype.getStage = function(time) {
      var stage, transition;
      if (time <= this.startTime) {
        return 0;
      }
      if (time >= this.endTime) {
        return 1;
      }
      stage = (time - this.startTime) / this.options.duration;
      transition = this.transitions[this.options.transition];
      if (typeof transition === 'function') {
        return transition(stage);
      } else {
        throw "Unknown transition: " + this.options.transition;
      }
    };

    Transformation.prototype.getValue = function(from, to, stage) {
      if (typeof from === 'number') {
        return (from * (1 - stage)) + (to * stage);
      }
      if (from.__isColor) {
        return new Color(this.getValue(from.r, to.r, stage), this.getValue(from.g, to.g, stage), this.getValue(from.b, to.b, stage), this.getValue(from.a, to.a, stage));
      }
      return to;
    };

    Transformation.prototype.progress = function(element, time) {
      var from, option, options, stage, to;
      if (this.finished) {
        return;
      }
      if (time < this.startTime) {
        return;
      }
      options = {};
      stage = this.getStage(time);
      from = this.options.from;
      to = this.options.to;
      for (option in to) {
        options[option] = this.getValue(from[option], to[option], stage);
      }
      element.set(options);
      if (time >= this.endTime) {
        this.finished = true;
        delete this.options.to;
        return delete this.options.from;
      }
    };

    return Transformation;

  })(ObjectAbstract);

  rippl.ImageAsset = ImageAsset = (function(_super) {

    __extends(ImageAsset, _super);

    ImageAsset.prototype.__isAsset = true;

    ImageAsset.prototype.__isLoaded = false;

    ImageAsset.prototype._width = 0;

    ImageAsset.prototype._height = 0;

    function ImageAsset(url) {
      var _this = this;
      this._image = new Image;
      this._image.onload = function() {
        _this.__isLoaded = true;
        _this._width = _this._image.naturalWidth;
        _this._height = _this._image.naturalHeight;
        return _this.trigger('loaded');
      };
      this._image.src = url;
    }

    ImageAsset.prototype.getDocumentElement = function() {
      if (this.__isLoaded) {
        return this._image;
      }
      return null;
    };

    return ImageAsset;

  })(ObjectAbstract);

  rippl.assets = {
    _assets: {},
    get: function(url) {
      if (this._assets[url] !== void 0) {
        return this._assets[url];
      }
      return this._assets[url] = new ImageAsset(url);
    },
    define: function(url, dataurl) {
      return this._assets[url] = new ImageAsset(dataurl);
    },
    preload: function(urls, callback) {
      var asset, count, url, _j, _len1, _results;
      if (typeof urls === 'string') {
        urls = [urls];
      }
      count = urls.length;
      _results = [];
      for (_j = 0, _len1 = urls.length; _j < _len1; _j++) {
        url = urls[_j];
        asset = this.get(url);
        if (asset.__isLoaded) {
          count -= 1;
          if (count === 0 && typeof callback === 'function') {
            _results.push(callback());
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(asset.on('loaded', function() {
            count -= 1;
            if (count === 0 && typeof callback === 'function') {
              return callback();
            }
          }));
        }
      }
      return _results;
    }
  };

  Element = (function(_super) {

    __extends(Element, _super);

    Element.prototype.options = {
      x: 0,
      y: 0,
      z: 0,
      snap: false,
      anchorX: 0.5,
      anchorY: 0.5,
      anchorInPixels: false,
      width: 0,
      height: 0,
      alpha: 1.0,
      rotation: 0.0,
      scaleX: 1.0,
      scaleY: 1.0,
      skewX: 0,
      skewY: 0,
      hidden: false,
      composition: 'source-over'
    };

    Element.prototype.tranformStack = [];

    Element.prototype.canvas = null;

    Element.prototype.__isElement = true;

    function Element(options) {
      this.setOptions(options);
      this.validate(this.options);
      this.transformStack = [];
      this.transformCount = 0;
    }

    Element.prototype.validate = function(options) {};

    Element.prototype.validateColor = function(value) {
      if (!value.__isColor) {
        value = new Color(value);
      }
      return value;
    };

    Element.prototype.getAnchor = function() {
      if (this.options.anchorInPixels) {
        return {
          x: this.options.anchorX,
          y: this.options.anchorY
        };
      } else {
        return {
          x: this.options.anchorX * this.options.width,
          y: this.options.anchorY * this.options.height
        };
      }
    };

    Element.prototype.hide = function() {
      if (this.options.hidden) {
        return;
      }
      this.options.hidden = true;
      return this.canvas.touch();
    };

    Element.prototype.show = function() {
      if (!this.options.hidden) {
        return;
      }
      this.options.hidden = false;
      return this.canvas.touch();
    };

    Element.prototype.isHidden = function() {
      return this.options.hidden;
    };

    Element.prototype.transform = function(options) {
      var option, transform, _ref, _ref1;
      if (typeof options.to !== 'object') {
        return;
      }
            if ((_ref = options.from) != null) {
        _ref;

      } else {
        options.from = {};
      };
            if ((_ref1 = options.to) != null) {
        _ref1;

      } else {
        options.to = {};
      };
      for (option in options.to) {
        if (options.from[option] === void 0) {
          options.from[option] = this.options[option];
        }
      }
      for (option in options.from) {
        if (options.to[option] === void 0) {
          options.to[option] = this.options[option];
        }
      }
      this.validate(options.from);
      this.validate(options.to);
      transform = new Transformation(options);
      this.transformStack.push(transform);
      this.transformCount += 1;
      return transform;
    };

    Element.prototype.progress = function(frameTime) {
      var newStack, transform, _j, _len1, _ref;
      if (!this.transformCount) {
        return;
      }
      newStack = [];
      _ref = this.transformStack;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        transform = _ref[_j];
        transform.progress(this, frameTime);
        if (!transform.isFinished()) {
          newStack.push(transform);
        }
      }
      this.transformStack = newStack;
      return this.transformCount = newStack.length;
    };

    Element.prototype.prepare = function() {
      var ctx, x, y;
      ctx = this.canvas.ctx;
      if (this.options.snap) {
        x = ~~this.options.x;
        y = ~~this.options.y;
      } else {
        x = this.options.x;
        y = this.options.y;
      }
      ctx.setTransform(this.options.scaleX, this.options.skewX, this.options.skewY, this.options.scaleY, x, y);
      if (this.options.alpha !== 1) {
        ctx.globalAlpha = this.options.alpha;
      }
      if (this.options.rotation !== 0) {
        ctx.rotate(this.options.rotation);
      }
      if (this.options.composition !== 'source-over') {
        return ctx.globalCompositeOperation = this.options.composition;
      }
    };

    Element.prototype.render = function() {};

    Element.prototype.set = function(target, value) {
      var change, option, _j, _len1;
      if (value !== void 0 && typeof target === 'string') {
        option = target;
        this.validate({
          option: target
        });
        if (this.options[option] !== void 0 && this.options[option] !== value) {
          this.options[option] = value;
          this.trigger("change:" + option);
          this.trigger("change");
          return;
        }
      }
      change = [];
      this.validate(target);
      for (option in target) {
        value = target[option];
        if (this.options[option] !== void 0 && this.options[option] !== value) {
          this.options[option] = value;
          change.push(option);
        }
      }
      if (change.length) {
        for (_j = 0, _len1 = change.length; _j < _len1; _j++) {
          option = change[_j];
          this.trigger("change:" + option);
        }
        return this.trigger("change");
      }
    };

    Element.prototype.get = function(option) {
      return this.options[option];
    };

    return Element;

  })(ObjectAbstract);

  rippl.Sprite = Sprite = (function(_super) {

    __extends(Sprite, _super);

    Sprite.prototype.buffer = null;

    Sprite.prototype._animated = false;

    Sprite.prototype._frameDuration = 0;

    Sprite.prototype._framesModulo = 0;

    function Sprite(options, canvas) {
      this.addDefaults({
        src: null,
        cropX: 0,
        cropY: 0,
        fps: 0
      });
      Sprite.__super__.constructor.call(this, options, canvas);
      if (this.options.fps !== 0) {
        this._frameDuration = 1000 / options.fps;
      }
    }

    Sprite.prototype.validate = function(options) {
      var asset,
        _this = this;
      if (typeof options.src === 'string') {
        options.src = asset = rippl.assets.get(options.src);
        if (!asset.__isLoaded) {
          asset.on('loaded', function() {
            if (_this.canvas) {
              _this.canvas.touch();
            }
            return _this.calculateFrames();
          });
        } else {
          this.calculateFrames();
        }
      }
      if (typeof options.fps === 'number') {
        if (options.fps === 0) {
          return this.stop();
        } else {
          return this._frameDuration = 1000 / options.fps;
        }
      }
    };

    Sprite.prototype.calculateFrames = function() {
      return this._framesModulo = ~~(this.options.src._width / this.options.width);
    };

    Sprite.prototype.render = function() {
      var anchor;
      anchor = this.getAnchor();
      if (this.buffer != null) {
        return this.canvas.drawSprite(this.buffer, -anchor.x, -anchor.y, this.options.width, this.options.height);
      } else {
        return this.canvas.drawSprite(this.options.src, -anchor.x, -anchor.y, this.options.width, this.options.height, this.options.cropX, this.options.cropY);
      }
    };

    Sprite.prototype.addAnimation = function(label, frames) {
      var animations;
      animations = this._animations || (this._animations = {});
      animations[label] = frames;
      return this;
    };

    Sprite.prototype.animate = function(label) {
            if (label != null) {
        label;

      } else {
        label = 'idle';
      };
      this._frames = this._animations[label];
      this._currentIndex = -1;
      this._animationStart = Date.now();
      this._animationEnd = this._animationStart + this._frames.length * this._frameDuration;
      return this._animated = true;
    };

    Sprite.prototype.progress = function(frameTime) {
      var frame, frameX, frameY, index;
      Sprite.__super__.progress.call(this, frameTime);
      if (this._animated && this._framesModulo) {
        if (frameTime >= this._animationEnd) {
          return this.animate();
        }
        index = ~~((frameTime - this._animationStart) / this._frameDuration);
        if (index !== this._currentIndex) {
          this._currentIndex = index;
          frame = this._frames[index];
          frameX = frame % this._framesModulo;
          frameY = ~~(frame / this._framesModulo);
          this.options.cropX = frameX * this.options.width;
          this.options.cropY = frameY * this.options.height;
          return this.canvas.touch();
        }
      }
    };

    Sprite.prototype.stop = function() {
      return this._animated = false;
    };

    Sprite.prototype.createBuffer = function() {
      delete this.buffer;
      this.buffer = new Canvas({
        width: this.options.width,
        height: this.options.height
      });
      return this.buffer.drawSprite(this.options.src, 0, 0, this.options.width, this.options.height, this.options.cropX, this.options.cropY);
    };

    Sprite.prototype.clearFilters = function() {
      if (!(this.buffer != null)) {
        return;
      }
      this.buffer.clear();
      return this.buffer.drawSprite(this.options.src, 0, 0, this.options.width, this.options.height, this.options.cropX, this.options.cropY);
    };

    Sprite.prototype.removeFilters = function() {
      delete this.buffer;
      this.buffer = null;
      return this.canvas.touch();
    };

    return Sprite;

  })(Element);

  Shape = (function(_super) {

    __extends(Shape, _super);

    function Shape(options, canvas) {
      this.addDefaults({
        stroke: 0,
        strokeColor: '#000',
        lineCap: 'butt',
        lineJoin: 'miter',
        erase: false,
        fill: true,
        color: '#000',
        shadow: false,
        shadowX: 0,
        shadowY: 0,
        shadowBlur: 0,
        shadowColor: '#000'
      });
      Shape.__super__.constructor.call(this, options, canvas);
    }

    Shape.prototype.validate = function(options) {
      if (options.color !== void 0) {
        options.color = this.validateColor(options.color);
      }
      if (options.strokeColor !== void 0) {
        options.strokeColor = this.validateColor(options.strokeColor);
      }
      if (options.shadowColor !== void 0) {
        return options.shadowColor = this.validateColor(options.shadowColor);
      }
    };

    Shape.prototype.drawPath = function() {};

    Shape.prototype.render = function() {
      var ctx;
      if (this.options.shadow) {
        this.canvas.setShadow(this.options.shadowX, this.options.shadowY, this.options.shadowBlur, this.options.shadowColor);
      }
      ctx = this.canvas.ctx;
      ctx.beginPath();
      ctx.lineCap = this.options.lineCap;
      ctx.lineJoin = this.options.lineJoin;
      this.drawPath();
      if (this.options.erase) {
        ctx.save();
        ctx.globalCompositeOperation = 'destination-out';
        ctx.globalAlpha = 1.0;
        this.canvas.fill('#000000');
        ctx.restore();
      }
      if (this.options.fill) {
        this.canvas.fill(this.options.color);
      }
      if (this.options.stroke > 0) {
        return this.canvas.stroke(this.options.stroke, this.options.strokeColor);
      }
    };

    return Shape;

  })(Element);

  rippl.Text = Text = (function(_super) {

    __extends(Text, _super);

    function Text(options, canvas) {
      this.addDefaults({
        label: 'Rippl',
        align: 'center',
        baseline: 'middle',
        italic: false,
        bold: false,
        size: 12,
        font: 'sans-serif'
      });
      Text.__super__.constructor.call(this, options, canvas);
    }

    Text.prototype.render = function() {
      var font;
      if (this.options.shadow) {
        this.canvas.setShadow(this.options.shadowX, this.options.shadowY, this.options.shadowBlur, this.options.shadowColor);
      }
      if (this.options.fill) {
        this.canvas.ctx.fillStyle = this.options.color.toString();
      }
      this.canvas.ctx.textAlign = this.options.align;
      this.canvas.ctx.textBaseline = this.options.baseline;
      font = [];
      if (this.options.italic) {
        font.push('italic');
      }
      if (this.options.bold) {
        font.push('bold');
      }
      font.push("" + this.options.size + "px");
      font.push(this.options.font);
      this.canvas.ctx.font = font.join(' ');
      if (this.options.fill) {
        this.canvas.ctx.fillText(this.options.label, 0, 0);
      }
      if (this.options.stroke) {
        this.canvas.ctx.lineWidth = this.options.stroke;
        this.canvas.ctx.strokeStyle = this.options.strokeColor.toString();
        return this.canvas.ctx.strokeText(this.options.label, 0, 0);
      }
    };

    return Text;

  })(Shape);

  rippl.Rectangle = Rectangle = (function(_super) {

    __extends(Rectangle, _super);

    function Rectangle(options, canvas) {
      this.addDefaults({
        radius: 0
      });
      Rectangle.__super__.constructor.call(this, options, canvas);
    }

    Rectangle.prototype.drawPath = function() {
      var anchor, ctx, h, r, w, x, y;
      anchor = this.getAnchor();
      ctx = this.canvas.ctx;
      if (this.options.radius === 0) {
        return ctx.rect(-anchor.x, -anchor.y, this.options.width, this.options.height);
      } else {
        x = -anchor.x;
        y = -anchor.y;
        w = this.options.width;
        h = this.options.height;
        r = this.options.radius;
        ctx.moveTo(x + w - r, y);
        ctx.quadraticCurveTo(x + w, y, x + w, y + r);
        ctx.lineTo(x + w, y + h - r);
        ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
        ctx.lineTo(x + r, y + h);
        ctx.quadraticCurveTo(x, y + h, x, y + h - r);
        ctx.lineTo(x, y + r);
        ctx.quadraticCurveTo(x, y, x + r, y);
        return ctx.closePath();
      }
    };

    return Rectangle;

  })(Shape);

  rippl.Circle = Circle = (function(_super) {

    __extends(Circle, _super);

    function Circle(options, canvas) {
      this.addDefaults({
        radius: 0,
        angle: Math.PI * 2
      });
      Circle.__super__.constructor.call(this, options, canvas);
      this.options.width = this.options.radius * 2;
      this.options.height = this.options.radius * 2;
    }

    Circle.prototype.drawPath = function() {
      var ctx;
      ctx = this.canvas.ctx;
      ctx.arc(0, 0, this.options.radius, 0, this.options.angle, false);
      if (this.options.angle !== Math.PI * 2) {
        ctx.lineTo(0, 0);
      }
      return ctx.closePath();
    };

    return Circle;

  })(Shape);

  rippl.Ellipse = Ellipse = (function(_super) {

    __extends(Ellipse, _super);

    function Ellipse() {
      return Ellipse.__super__.constructor.apply(this, arguments);
    }

    Ellipse.prototype.drawPath = function() {
      var anchor, ctx, h, magic, ox, oy, w, x, xe, xm, y, ye, ym;
      anchor = this.getAnchor();
      ctx = this.canvas.ctx;
      x = -anchor.x;
      y = -anchor.y;
      w = this.options.width;
      h = this.options.height;
      magic = 0.551784;
      ox = (w / 2) * magic;
      oy = (h / 2) * magic;
      xe = x + w;
      ye = y + h;
      xm = x + w / 2;
      ym = y + h / 2;
      ctx.moveTo(x, ym);
      ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y);
      ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym);
      ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye);
      ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym);
      return ctx.closePath();
    };

    return Ellipse;

  })(Shape);

  rippl.CustomShape = CustomShape = (function(_super) {

    __extends(CustomShape, _super);

    function CustomShape(options, canvas) {
      this.addDefaults({
        rootX: 0,
        rootY: 0,
        anchorX: 0,
        anchorY: 0
      });
      CustomShape.__super__.constructor.call(this, options, canvas);
      this.points = [];
      this.options.anchorInPixels = true;
    }

    CustomShape.prototype.drawPath = function() {
      var anchor, ctx, line, point, x, y, _j, _len1, _ref, _results;
      anchor = this.getAnchor();
      ctx = this.canvas.ctx;
      ctx.moveTo(this.options.rootX - anchor.x, this.options.rootY - anchor.y);
      _ref = this.points;
      _results = [];
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        point = _ref[_j];
        if (point === null) {
          _results.push(ctx.closePath());
        } else {
          x = point[0], y = point[1], line = point[2];
          if (line) {
            _results.push(ctx.lineTo(x - anchor.x, y - anchor.y));
          } else {
            _results.push(ctx.moveTo(x - anchor.x, y - anchor.y));
          }
        }
      }
      return _results;
    };

    CustomShape.prototype.lineTo = function(x, y) {
      return this.points.push([x, y, true]);
    };

    CustomShape.prototype.moveTo = function(x, y) {
      return this.points.push([x, y, false]);
    };

    CustomShape.prototype.close = function() {
      return this.points.push(null);
    };

    return CustomShape;

  })(Shape);

  rippl.Canvas = Canvas = (function(_super) {

    __extends(Canvas, _super);

    Canvas.prototype.options = {
      id: null,
      width: 0,
      height: 0
    };

    Canvas.prototype.__isAsset = true;

    Canvas.prototype.changed = false;

    Canvas.prototype.unordered = false;

    function Canvas(options) {
      this.setOptions(options);
      if (this.options.id !== null) {
        this._canvas = document.getElementById(this.options.id);
        this._width = this.options.width = Number(this._canvas.width);
        this._height = this.options.height = Number(this._canvas.height);
      } else {
        this._canvas = document.createElement('canvas');
        this._width = this._canvas.setAttribute('width', this.options.width);
        this._height = this._canvas.setAttribute('height', this.options.height);
      }
      this.ctx = this._canvas.getContext('2d');
      this.ctx.save();
      this.elements = [];
    }

    Canvas.prototype.getDocumentElement = function() {
      return this._canvas;
    };

    Canvas.prototype.fill = function(color) {
      this.ctx.fillStyle = color.toString();
      return this.ctx.fill();
    };

    Canvas.prototype.stroke = function(width, color) {
      this.ctx.lineWidth = width;
      this.ctx.strokeStyle = color.toString();
      return this.ctx.stroke();
    };

    Canvas.prototype.setShadow = function(x, y, blur, color) {
            if (x != null) {
        x;

      } else {
        x = 0;
      };
            if (y != null) {
        y;

      } else {
        y = 0;
      };
            if (blur != null) {
        blur;

      } else {
        blur = 0;
      };
            if (color != null) {
        color;

      } else {
        color = '#000000';
      };
      this.ctx.shadowOffsetX = x;
      this.ctx.shadowOffsetY = y;
      this.ctx.shadowBlur = blur;
      return this.ctx.shadowColor = color.toString();
    };

    Canvas.prototype.add = function(element) {
      var _this = this;
      if (!element.__isElement) {
        throw "Tried to add a non-Element to Canvas";
      }
      element.canvas = this;
      this.elements.push(element);
      this.touch();
      this.unordered = true;
      element.on('change', function() {
        return _this.touch();
      });
      element.on('change:z', function() {
        return _this.unordered = true;
      });
      return element;
    };

    Canvas.prototype.remove = function(elementToDelete) {
      var element, filtered, _j, _len1, _ref;
      filtered = [];
      _ref = this.elements;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        element = _ref[_j];
        if (element !== elementToDelete) {
          filtered.push(element);
        } else {
          element.off();
          delete element.canvas;
        }
      }
      this.elements = filtered;
      return this.touch();
    };

    Canvas.prototype.wipe = function() {
      var element, _j, _len1, _ref;
      _ref = this.elements;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        element = _ref[_j];
        delete element.canvas;
      }
      this.elements = [];
      return this.touch();
    };

    Canvas.prototype.reorder = function() {
      this.elements.sort(function(a, b) {
        return a.get('z') - b.get('z');
      });
      return this.unordered = false;
    };

    Canvas.prototype.touch = function() {
      return this.changed = true;
    };

    Canvas.prototype.clear = function() {
      return this.ctx.clearRect(0, 0, this.options.width, this.options.height);
    };

    Canvas.prototype.render = function(frameTime) {
      var element, _j, _k, _len1, _len2, _ref, _ref1;
      _ref = this.elements;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        element = _ref[_j];
        element.progress(frameTime);
      }
      if (!this.changed) {
        return;
      }
      if (this.unordered) {
        this.reorder();
      }
      this.clear();
      _ref1 = this.elements;
      for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
        element = _ref1[_k];
        if (!element.isHidden()) {
          this.ctx.save();
          element.prepare();
          element.render();
          this.ctx.restore();
        }
      }
      return this.changed = false;
    };

    Canvas.prototype.drawSprite = function(asset, x, y, width, height, cropX, cropY) {
      var element;
      if (!asset.__isAsset) {
        throw "Canvas.drawSprite: invalid asset";
      }
      element = asset.getDocumentElement();
      if (!element) {
        return;
      }
            if (cropX != null) {
        cropX;

      } else {
        cropX = 0;
      };
            if (cropY != null) {
        cropY;

      } else {
        cropY = 0;
      };
      x = Math.round(x);
      y = Math.round(y);
      return this.ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height);
    };

    Canvas.prototype.rgbaFilter = function(filter) {
      var i, imageData, l, pixels, _ref;
      imageData = this.ctx.getImageData(0, 0, this.options.width, this.options.height);
      pixels = imageData.data;
      i = 0;
      l = pixels.length;
      while (i < l) {
        _ref = filter(pixels[i], pixels[i + 1], pixels[i + 2], pixels[i + 3]), pixels[i] = _ref[0], pixels[i + 1] = _ref[1], pixels[i + 2] = _ref[2], pixels[i + 3] = _ref[3];
        i += 4;
      }
      return this.ctx.putImageData(imageData, 0, 0);
    };

    return Canvas;

  })(ObjectAbstract);

  if (typeof define === 'function') {
    define(window.rippl);
  }

}).call(this);
