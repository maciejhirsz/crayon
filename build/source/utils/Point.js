var Point = crayon.Point = (function() {
    function Point(x, y) {
        this.__isPoint = true;
        this.x = x;
        this.y = y;
    }

    extend(Point, EventEmitter);
    methods(Point,
        function move(x, y) {
            if (this.x === x && this.y === y) return;
            if (x != null) this.x = x;
            if (y != null) this.y = y;
            this.trigger('move', this);
        }
    );

    return Point;
})();