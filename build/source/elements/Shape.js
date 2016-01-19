var Shape = crayon.Shape = (function() {
    function Shape() {
        Element.apply(this, arguments);
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

        function drawPath() {
        },

        function render() {
            if (this.options.shadow) {
                this.canvas.setShadow(
                    this.options.shadowX,
                    this.options.shadowY,
                    this.options.shadowBlur,
                    this.options.shadowColor
                );
            }

            ctx = this.canvas.ctx;
            ctx.beginPath();

            // Set line properties
            ctx.lineCap = this.options.lineCap;
            ctx.lineJoin = this.options.lineJoin;

            // Draw path
            this.drawPath();

            // Erase background before drawing?
            if (this.options.erase) {
                ctx.save();
                ctx.globalCompositeOperation = 'destination-out';
                ctx.globalAlpha = 1.0;
                this.canvas.fill('//000000');
                ctx.restore();
            }

            // Fill and stroke if applicable
            if (this.options.fill) this.canvas.fill(this.options.color);
            if (this.options.stroke > 0) this.canvas.stroke(this.options.stroke, this.options.strokeColor);

            // ctx.closePath()
        }
    );

    return Shape;
})();