var Rectangle = crayon.Rectangle = (function() {
    function Rectangle() {
        Shape.apply(this, arguments);
    }

    extend(Rectangle, Shape);
    defaults(Rectangle, {
        cornerRadius : 0 // radius of rounded corners
    });
    methods(Rectangle,
        function drawPath() {
            var anchor = this.getAnchor(),
                ctx    = this.canvas.ctx;

            if (this.options.cornerRadius === 0) {
                return ctx.rect(-anchor.x, -anchor.y, this.options.width, this.options.height);
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
            return ctx.closePath();
        }
    );

    return Rectangle;
})();