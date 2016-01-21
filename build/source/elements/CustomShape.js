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