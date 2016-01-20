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
                this.changed = true;
                this.unordered = true;

                this.listenTo(element, 'change', this.touch);
                this.listenTo(element, 'change:z', this.touchOrder);
            }
        },

        function remove(elementToRemove) {
            elementToRemove.stopListening();
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
            return this.unordered = false;
        },

        function touchOrder() {
            this.unordered = true;
        },

        function touch() {
            this.changed = true;
        },

        function clear() {
            this.ctx.clearRect(0, 0, this.options.width, this.options.height);
        },

        function render(frameTime) {
            var element, i, len = this.elements.length;
            for (i = 0; i < len; i++) {
                element = this.elements[i];
                element.progress(frameTime);
            }

            if (!this.changed) return;
            if (this.unordered) this.reorder();

            this.clear();
            for (i = 0; i < len; i++) {
                element = this.elements[i];
                if (element.isHidden()) continue;

                this.ctx.save();
                element.prepare(this);
                element.render(this);
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