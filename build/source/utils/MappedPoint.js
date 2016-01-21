var MappedPoint = crayon.MappedPoint = (function () {
    function noop(value) {
        return value;
    }

    /**
     * @param {function|null} mapX
     * @param {function|null} mapY
     * @param {Point} root
     * @constructor
     */
    function MappedPoint(mapX, mapY, root) {
        this.__isPoint = true;
        this.x = 0;
        this.y = 0;
        this.root = root;
        this.mapX = (mapX == null) ? noop : mapX;
        this.mapY = (mapY == null) ? noop : mapY;
        this.listenTo(root, 'move', this._update);
    }

    extend(MappedPoint, EventEmitter);
    methods(MappedPoint,
        function _update() {
            this.x = this.mapX(this.root.x);
            this.y = this.mapY(this.root.y);
            this.trigger('move');
        },

        function move(x, y) {
            this.root.move(x, y);
        }
    );

    return MappedPoint;
})();