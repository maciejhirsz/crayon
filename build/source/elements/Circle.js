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