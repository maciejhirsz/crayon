var Sprite = crayon.Sprite = (function() {
    function Sprite(options) {
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
        function validate(options) {
            Element.prototype.validate.call(this, options);
            var asset;
            if (options.src !== undefined) {
                if (typeof options.src === 'string') {
                    options.src = asset = crayon.assets.get(options.src);
                } else {
                    asset = options.src;
                }

                if (!asset.__isLoaded) {
                    asset.once('loaded', function() {
                        this.trigger('change');
                        this.calculateFrames();
                        this.calculateAnchor();
                    }, this);
                } else {
                    this.calculateFrames();
                }
            }
        },

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

            return options.src.getPixelAlpha(x, y) === 0;
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

            this.trigger('change');
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
            this.trigger('change');
        },

        function clearFilters() {
            if (this.buffer == null) return;
            this.buffer.clear();
            this._drawSourceOnBuffer();
        },

        function removeFilter() {
            this.buffer = null;
            this._useBuffer = false;
            this.trigger('change');
        }
    );

    return Sprite;
})();