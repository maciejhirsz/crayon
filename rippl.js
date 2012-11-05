// Generated by CoffeeScript 1.4.0
/*
(c) 2012 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

(function() {
  var Canvas, Color, Element, ImageAsset, ObjectAbstract, Shape, Sprite, Text, Timer, Transformation, rippl;
  window.rippl = rippl = {};
  rippl.ObjectAbstract = ObjectAbstract = (function() {

    function ObjectAbstract() {}

    ObjectAbstract.prototype.options = {};

    ObjectAbstract.prototype._eventHandlers = null;

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
      if (!this._validEventName(event)) {
        return;
      }
      if (!this._validCallback(callback)) {
        return;
      }
      if (this._eventHandlers === null) {
        this._eventHandlers = {};
      }
      if (this._eventHandlers[event] === void 0) {
        this._eventHandlers[event] = [];
      }
      return this._eventHandlers[event].push(callback);
    };

    ObjectAbstract.prototype.off = function(event, callbackToRemove) {
      var callback, stack, _i, _len, _ref;
      if (this._eventHandlers === null) {
        return;
      }
      if (!this._validEventName(event)) {
        return this._eventHandlers = {};
      } else if (!this._validCallback(callbackToRemove)) {
        if (this._eventHandlers[event] === void 0) {
          return;
        }
        return delete this._eventHandlers[event];
      } else {
        if (this._eventHandlers[event] === void 0) {
          return;
        }
        stack = [];
        _ref = this._eventHandlers[event];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          callback = _ref[_i];
          if (callback !== callbackToRemove) {
            stack.push(callback);
          }
        }
        return this._eventHandlers[event] = stack;
      }
    };

    ObjectAbstract.prototype.trigger = function(event, data) {
      var callback, _i, _len, _ref;
      if (this._eventHandlers === null) {
        return;
      }
      if (!this._validEventName(event)) {
        return;
      }
      if (this._eventHandlers[event] === void 0) {
        return false;
      }
      _ref = this._eventHandlers[event];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        callback(data);
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
  rippl.Timer = Timer = (function(_super) {

    __extends(Timer, _super);

    Timer.prototype.options = {
      fps: 40,
      autoStart: true,
      fixedFrames: false
    };

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
      this.time = this.getTime();
      return this.timerid = setTimeout(function() {
        return _this.tick();
      }, this.frameDuration);
    };

    Timer.prototype.stop = function() {
      return clearTimeout(this.timerid);
    };

    Timer.prototype.getTime = function() {
      return (new Date).getTime();
    };

    Timer.prototype.getSeconds = function() {
      return Math.floor((new Date).getTime() / 1000);
    };

    Timer.prototype.tick = function() {
      var canvas, delay, frameTime, iterations, postRenderTime, _i, _len, _ref,
        _this = this;
      frameTime = this.getTime();
      if (this.options.fixedFrames) {
        iterations = ~~((frameTime - this.time) / this.frameDuration) + 1;
        if (iterations < 1) {
          iterations = 1;
        }
        if (iterations > 100) {
          iterations = 100;
        }
        this.time += this.frameDuration * iterations;
        while (iterations) {
          this.trigger('frame', frameTime);
          iterations -= 1;
        }
      } else {
        this.time += this.frameDuration;
        this.trigger('frame', frameTime);
      }
      _ref = this.canvas;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        canvas = _ref[_i];
        canvas.render(frameTime);
      }
      postRenderTime = this.getTime();
      delay = this.time - postRenderTime;
      if (delay < 0) {
        delay = 0;
        if (!this.options.fixedFrames) {
          this.time = postRenderTime;
        }
      }
      return setTimeout(function() {
        return _this.tick();
      }, delay);
    };

    return Timer;

  })(ObjectAbstract);
  rippl.Color = Color = (function() {

    Color.prototype.r = 255;

    Color.prototype.g = 255;

    Color.prototype.b = 255;

    Color.prototype.a = 255;

    Color.prototype.__isColor = true;

    Color.prototype.string = '#ffffff';

    function Color(r, g, b, a) {
      var hash, l;
      if (typeof r === 'string' && r[0] === '#') {
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
        }
      }
      this.set(r, g, b, a);
    }

    Color.prototype.set = function(r, g, b, a) {
      this.r = ~~r;
      this.g = ~~g;
      this.b = ~~b;
      if (a !== void 0) {
        this.a = ~~a;
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
      this.startTime = (new Date).getTime() + this.options.delay;
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
      if (time < this.startTime) {
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
    };

    Transformation.prototype.progress = function(element, time) {
      var from, option, options, stage, to;
      if (this.finished) {
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

    function ImageAsset(url) {
      var _this = this;
      this._image = new Image;
      this._image.onload = function() {
        _this.__isLoaded = true;
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
    preload: function(urls, callback) {
      var asset, count, url, _i, _len, _results;
      if (typeof urls === 'string') {
        urls = [urls];
      }
      count = urls.length;
      _results = [];
      for (_i = 0, _len = urls.length; _i < _len; _i++) {
        url = urls[_i];
        asset = this.get(url);
        if (asset.__isLoaded) {
          count -= 1;
          if (count === 0) {
            _results.push(callback());
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(asset.on('loaded', function() {
            count -= 1;
            if (count === 0) {
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
      var newStack, transform, _i, _len, _ref;
      if (!this.transformCount) {
        return;
      }
      newStack = [];
      _ref = this.transformStack;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        transform = _ref[_i];
        transform.progress(this, frameTime);
        if (!transform.isFinished()) {
          newStack.push(transform);
        }
      }
      this.transformStack = newStack;
      return this.transformCount = newStack.length;
    };

    Element.prototype.prepare = function() {
      this.canvas.ctx.setTransform(this.options.scaleX, this.options.skewX, this.options.skewY, this.options.scaleY, this.options.x, this.options.y);
      if (this.options.alpha !== 1) {
        this.canvas.setAlpha(this.options.alpha);
      }
      if (this.options.rotation !== 0) {
        this.canvas.setRotation(this.options.rotation);
      }
      if (this.options.composition !== 'source-over') {
        return this.canvas.ctx.globalCompositeOperation = this.options.composition;
      }
    };

    Element.prototype.render = function() {};

    Element.prototype.set = function(target, value) {
      var change, option, _i, _len;
      if (value !== void 0 && typeof target === 'string') {
        option = target;
        if (this.options[option] !== void 0 && this.options[option] !== value) {
          this.options[option] = value;
          this.validate(this.options);
          this.trigger("change:" + option);
          this.trigger("change");
          return;
        }
      }
      change = [];
      for (option in target) {
        value = target[option];
        if (this.options[option] !== void 0 && this.options[option] !== value) {
          this.options[option] = value;
          change.push(option);
        }
      }
      if (change.length) {
        this.validate(this.options);
        for (_i = 0, _len = change.length; _i < _len; _i++) {
          option = change[_i];
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

    Sprite.prototype.animated = false;

    Sprite.prototype.count = 0;

    Sprite.playFrames = [];

    Sprite.prototype.currentFrame = 0;

    function Sprite(options, canvas) {
      this.addDefaults({
        src: null,
        cropX: 0,
        cropY: 0
      });
      Sprite.__super__.constructor.call(this, options, canvas);
      this.frames = [];
    }

    Sprite.prototype.validate = function(options) {
      var asset,
        _this = this;
      if (options.src === null) {
        throw "Sprite: src option can't be null";
      }
      if (typeof options.src === 'string') {
        options.src = asset = rippl.assets.get(options.src);
        if (!asset.__isLoaded) {
          return asset.on('loaded', function() {
            return _this.canvas.touch();
          });
        }
      }
    };

    Sprite.prototype.setFrame = function(index) {
      var frame;
      frame = this.frames[index];
      this.options.cropX = frame[0];
      this.options.cropY = frame[1];
      return this.removeFilters();
    };

    Sprite.prototype.render = function() {
      var anchor;
      if (this.animated && this.count % this.animated === 0) {
        this.setFrame(this.playFrames[this.currentFrame]);
        this.currentFrame += 1;
        if (this.currentFrame === this.playFrames.length) {
          this.currentFrame = 0;
        }
      }
      anchor = this.getAnchor();
      if (this.buffer != null) {
        return this.canvas.drawSprite(this.buffer, -anchor.x, -anchor.y, this.options.width, this.options.height);
      } else {
        return this.canvas.drawSprite(this.options.src, -anchor.x, -anchor.y, this.options.width, this.options.height, this.options.cropX, this.options.cropY);
      }
    };

    Sprite.prototype.createBuffer = function() {
      delete this.buffer;
      this.buffer = this.canvas.newCanvas({
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

    Sprite.prototype.invertColorsFilter = function() {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.invertColorsFilter();
    };

    Sprite.prototype.saturationFilter = function(saturation) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.saturationFilter(saturation);
    };

    Sprite.prototype.contrastFilter = function(contrast) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.contrastFilter(contrast);
    };

    Sprite.prototype.brightnessFilter = function(brightness) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.brightnessFilter(brightness);
    };

    Sprite.prototype.gammaFilter = function(gamma) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.gammaFilter(gamma);
    };

    Sprite.prototype.hueShiftFilter = function(shift) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.hueShiftFilter(shift);
    };

    Sprite.prototype.colorizeFilter = function(hue) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.colorizeFilter(hue);
    };

    Sprite.prototype.ghostFilter = function(alpha) {
      if (!(this.buffer != null)) {
        this.createBuffer();
      }
      return this.buffer.ghostFilter(alpha);
    };

    Sprite.prototype.animate = function(interval, from, to) {
      var _i, _results;
            if (interval != null) {
        interval;

      } else {
        interval = 1;
      };
      if (from === void 0) {
        from = 0;
      }
      if (to === void 0) {
        to = this.frames.length - 1;
      }
      this.playFrames = (function() {
        _results = [];
        for (var _i = from; from <= to ? _i <= to : _i >= to; from <= to ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      this.currentFrame = 0;
      if (this.playFrames.length) {
        this.count = 0;
        return this.animated = interval;
      }
    };

    Sprite.prototype.stop = function() {
      this.playFrames = [];
      return this.animated = 0;
    };

    Sprite.prototype.addFrame = function(cropX, cropY) {
      return this.frames.push([cropX, cropY]);
    };

    return Sprite;

  })(Element);
  rippl.Shape = Shape = (function(_super) {

    __extends(Shape, _super);

    function Shape(options, canvas) {
      this.addDefaults({
        type: 'rectangle',
        rootX: 0,
        rootY: 0,
        radius: 0,
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
      this.points = [];
      Shape.__super__.constructor.call(this, options, canvas);
      if (this.options.type === 'custom') {
        this.options.anchorInPixels = true;
      }
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

    Shape.prototype.render = function() {
      var anchor, point, x, y, _i, _len, _ref;
      if (this.options.shadow) {
        this.canvas.setShadow(this.options.shadowX, this.options.shadowY, this.options.shadowBlur, this.options.shadowColor);
      }
      this.canvas.ctx.beginPath();
      anchor = this.getAnchor();
      this.canvas.ctx.lineCap = this.options.lineCap;
      this.canvas.ctx.lineJoin = this.options.lineJoin;
      switch (this.options.type) {
        case "custom":
          this.canvas.ctx.moveTo(this.options.rootX - anchor.x, this.options.rootY - anchor.y);
          _ref = this.points;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            point = _ref[_i];
            if (point === null) {
              this.canvas.ctx.closePath();
            } else {
              x = point[0], y = point[1];
              this.canvas.ctx.lineTo(x - anchor.x, y - anchor.y);
            }
          }
          break;
        case "circle":
          this.canvas.ctx.arc(0, 0, this.options.radius, 0, Math.PI * 2, false);
          break;
        default:
          if (this.options.radius === 0) {
            this.canvas.ctx.rect(-anchor.x, -anchor.y, this.options.width, this.options.height);
          } else {
            this.roundRect(-anchor.x, -anchor.y, this.options.width, this.options.height, this.options.radius);
          }
      }
      if (this.options.erase) {
        if (this.options.type === 'rectangle' && this.options.radius === 0) {
          this.canvas.ctx.clearRect(-anchor.x, -anchor.y, this.options.width, this.options.height);
        } else {
          this.canvas.ctx.save();
          this.canvas.ctx.globalCompositeOperation = 'destination-out';
          this.canvas.ctx.globalAlpha = 1.0;
          this.canvas.fill('#000000');
          this.canvas.ctx.restore();
        }
      }
      if (this.options.fill) {
        this.canvas.fill(this.options.color);
      }
      if (this.options.stroke > 0) {
        this.canvas.stroke(this.options.stroke, this.options.strokeColor);
      }
      return this.canvas.ctx.closePath();
    };

    Shape.prototype.roundRect = function(x, y, width, height, radius) {
      this.canvas.ctx.moveTo(x + width - radius, y);
      this.canvas.ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
      this.canvas.ctx.lineTo(x + width, y + height - radius);
      this.canvas.ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
      this.canvas.ctx.lineTo(x + radius, y + height);
      this.canvas.ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
      this.canvas.ctx.lineTo(x, y + radius);
      this.canvas.ctx.quadraticCurveTo(x, y, x + radius, y);
      return this.canvas.ctx.closePath();
    };

    Shape.prototype.addPoint = function(x, y) {
      return this.points.push([x, y]);
    };

    Shape.prototype.close = function() {
      return this.points.push(null);
    };

    return Shape;

  })(Element);
  rippl.Text = Text = (function(_super) {

    __extends(Text, _super);

    function Text(options, canvas) {
      this.addDefaults({
        label: 'Surface',
        align: 'center',
        baseline: 'middle',
        color: '#000',
        fill: true,
        stroke: 0,
        strokeColor: '#000',
        italic: false,
        bold: false,
        size: 12,
        font: 'sans-serif',
        shadow: false,
        shadowX: 0,
        shadowY: 0,
        shadowBlur: 0,
        shadowColor: '#000'
      });
      Text.__super__.constructor.call(this, options, canvas);
    }

    Text.prototype.validate = function(options) {
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

  })(Element);
  return rippl.Canvas = Canvas = (function(_super) {

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
        this.options.width = Number(this._canvas.width);
        this.options.height = Number(this._canvas.height);
      } else {
        this._canvas = document.createElement('canvas');
        this._canvas.setAttribute('width', this.options.width);
        this._canvas.setAttribute('height', this.options.height);
      }
      this.ctx = this._canvas.getContext('2d');
      this.ctx.save();
      this.elements = [];
    }

    Canvas.prototype.getDocumentElement = function() {
      return this._canvas;
    };

    Canvas.prototype.getCanvas = function() {
      return this._canvas;
    };

    Canvas.prototype.newCanvas = function(options) {
      return new Canvas(options);
    };

    Canvas.prototype.createImage = function(url, callback) {
      var image;
      image = new Image;
      image.onload = function() {
        return callback(image);
      };
      return image.src = url;
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

    Canvas.prototype.setScale = function(x, y) {
      return this.ctx.scale(x, y);
    };

    Canvas.prototype.setAlpha = function(alpha) {
      return this.ctx.globalAlpha = alpha;
    };

    Canvas.prototype.setRotation = function(rotation) {
      return this.ctx.rotate(rotation);
    };

    Canvas.prototype.setPosition = function(x, y) {
      return this.ctx.translate(x, y);
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
      var element, filtered, _i, _len, _ref;
      filtered = [];
      _ref = this.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
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
      var element, _i, _len, _ref;
      _ref = this.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
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
      var element, _i, _j, _len, _len1, _ref, _ref1;
      _ref = this.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
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
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        element = _ref1[_j];
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

    Canvas.prototype.toDataUrl = function() {
      return this._canvas.toDataURL();
    };

    Canvas.prototype.rgbToLuma = function(r, g, b) {
      return 0.30 * r + 0.59 * g + 0.11 * b;
    };

    Canvas.prototype.rgbToChroma = function(r, g, b) {
      return Math.max(r, g, b) - Math.min(r, g, b);
    };

    Canvas.prototype.rgbToLumaChromaHue = function(r, g, b) {
      var chroma, hprime, hue, luma;
      luma = this.rgbToLuma(r, g, b);
      chroma = this.rgbToChroma(r, g, b);
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
    };

    Canvas.prototype.lumaChromaHueToRgb = function(luma, chroma, hue) {
      var b, component, g, hprime, r, sextant, x;
      hprime = hue / (Math.PI / 3);
      x = chroma * (1 - Math.abs(hprime % 2 - 1));
      sextant = ~~hprime;
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
      component = luma - this.rgbToLuma(r, g, b);
      r += component;
      g += component;
      b += component;
      return [r, g, b];
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

    Canvas.prototype.invertColorsFilter = function() {
      return this.rgbaFilter(function(r, g, b, a) {
        r = 255 - r;
        g = 255 - g;
        b = 255 - b;
        return [r, g, b, a];
      });
    };

    Canvas.prototype.saturationFilter = function(saturation) {
      var grayscale,
        _this = this;
      saturation += 1;
      grayscale = 1 - saturation;
      return this.rgbaFilter(function(r, g, b, a) {
        var luma;
        luma = _this.rgbToLuma(r, g, b);
        r = r * saturation + luma * grayscale;
        g = g * saturation + luma * grayscale;
        b = b * saturation + luma * grayscale;
        return [r, g, b, a];
      });
    };

    Canvas.prototype.contrastFilter = function(contrast) {
      var gray, original;
      gray = -contrast;
      original = 1 + contrast;
      return this.rgbaFilter(function(r, g, b, a) {
        r = r * original + 127 * gray;
        g = g * original + 127 * gray;
        b = b * original + 127 * gray;
        return [r, g, b, a];
      });
    };

    Canvas.prototype.brightnessFilter = function(brightness) {
      var change;
      change = 255 * brightness;
      return this.rgbaFilter(function(r, g, b, a) {
        r += change;
        g += change;
        b += change;
        return [r, g, b, a];
      });
    };

    Canvas.prototype.gammaFilter = function(gamma) {
      gamma += 1;
      return this.rgbaFilter(function(r, g, b, a) {
        r *= gamma;
        g *= gamma;
        b *= gamma;
        return [r, g, b, a];
      });
    };

    Canvas.prototype.hueShiftFilter = function(shift) {
      var fullAngle,
        _this = this;
      fullAngle = Math.PI * 2;
      shift = shift % fullAngle;
      return this.rgbaFilter(function(r, g, b, a) {
        var chroma, hue, luma, _ref, _ref1;
        _ref = _this.rgbToLumaChromaHue(r, g, b), luma = _ref[0], chroma = _ref[1], hue = _ref[2];
        hue = (hue + shift) % fullAngle;
        if (hue < 0) {
          hue += fullAngle;
        }
        _ref1 = _this.lumaChromaHueToRgb(luma, chroma, hue), r = _ref1[0], g = _ref1[1], b = _ref1[2];
        return [r, g, b, a];
      });
    };

    Canvas.prototype.colorizeFilter = function(hue) {
      var _this = this;
      hue = hue % (Math.PI * 2);
      return this.rgbaFilter(function(r, g, b, a) {
        var chroma, luma, _ref;
        luma = _this.rgbToLuma(r, g, b);
        chroma = _this.rgbToChroma(r, g, b);
        _ref = _this.lumaChromaHueToRgb(luma, chroma, hue), r = _ref[0], g = _ref[1], b = _ref[2];
        return [r, g, b, a];
      });
    };

    Canvas.prototype.ghostFilter = function(alpha) {
      var opacity,
        _this = this;
      opacity = 1 - alpha;
      return this.rgbaFilter(function(r, g, b, a) {
        var luma;
        luma = _this.rgbToLuma(r, g, b);
        a = (a / 255) * (luma * alpha + 255 * opacity);
        return [r, g, b, a];
      });
    };

    return Canvas;

  })(ObjectAbstract);
})(window);

if (typeof define === 'function') {
  define(window.rippl);
}
