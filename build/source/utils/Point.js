var Point = crayon.Point = (function() {
    function Point(x, y) {
        this.__isPoint = true;
        this.x = x;
        this.y = y;
        this.canvas = null;
    }

    extend(Point, EventEnabled);
    methods(Point,
        function bind(canvas) {
            this.canvas = canvas;
            return this;
        },

        function move(x, y) {
            if (this.x === x && this.y === y) return;
            if (x != null) this.x = x;
            if (y != null) this.y = y;
            if (this.canvas != null) this.canvas.touch();
            this.trigger('move', this);
            return this;
        }
    );

    return Point;
})();