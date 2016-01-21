var RelativePoint = crayon.RelativePoint = (function () {
    /**
     * @param {number} relX
     * @param {number} relY
     * @param {Point} root
     * @constructor
     */
    function RelativePoint(relX, relY, root) {
        this.__isPoint = true;
        this.x = 0;
        this.y = 0;
        this.root = root;
        this.relX = (relX == null) ? 0 : relX;
        this.relY = (relY == null) ? 0 : relY;
        this.listenTo(root, 'move', this._update);
    }

    extend(RelativePoint, EventEmitter);
    methods(RelativePoint,
        function _update() {
            this.x = this.root.x + this.relX;
            this.y = this.root.y + this.relY;
            this.trigger('move');
        },

        function move(relX, relY) {
            if (relX != null) this.relX = relX;
            if (relY != null) this.relY = relY;
            this._update();
        }
    );

    return RelativePoint;
})();