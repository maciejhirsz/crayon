var Element = (function() {
    function Element(options) {
        this.__isElement = true;
        this.canvas = null;
        this.transformStack = [];
        this.transformCount = 0;

        EventEnabled.apply(this, arguments);

        // Set the options using the defaults
        this.options = Object.assign({}, this.defaults, options);

        // validate after assigning to make sure position is bound to a point
        this.validate(this.options);

        // cache anchor position
        this.on('change:anchorX change:anchorY change:anchorInPixels', this.calculateAnchor, this);
        this.calculateAnchor();
    }

    extend(Element, EventEnabled);
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
        function validate(options) {
            if (options.position != null) {
                options.x = options.position.x;
                options.y = options.position.y;
                if (this.canvas != null) options.position.bind(this.canvas);
                return;
            }

            this.options.position = new Point(this.options.x, this.options.y);
            if (this.canvas != null) this.options.position.bind(this.canvas);
            if (options.x != null) this.options.position.move(options.x, null);
            if (options.y != null) this.options.position.move(null, options.y);
        },

        function bind(canvas) {
            this.canvas = canvas;
            if (this.options.position !== null) this.options.position.bind(canvas);
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
            this.canvas.touch();
        },

        function show() {
            if (!this.options.hidden) return;
            this.options.hidden = false;
            this.canvas.touch();
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

            this.tranformStack.each(function(transform) {
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
            if (!this.transformCount === 0) return;

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
        function prepare() {
            var ctx     = this.canvas.ctx,
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

        function render() {
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
            if (value !== undefined && typeof options === 'string') {
                var o = {};
                o[target] = value;
                options = o;
            }
            this.validate(options);

            var change = [], option;
            for (option in options) {
                value = options[option];
                if (this.options[option] !== undefined && this.options[option] !== value) {
                    this.options[option] = value;
                    change.push(option);
                }
            }
            if (change.length) {
                change.forEach(function(option) {
                    this.trigger('change' + option);
                }, this);
                this.trigger('change');
            }
        },

        function get(option) {
            return this.options[option];
        }
    );

    return Element;
})();