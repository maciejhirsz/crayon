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