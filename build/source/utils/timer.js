crayon.timer = (function() {
    var canvasStack = [],
        canvasCount = 0,
        time,
        timerid;

    function tick(timestamp) {
        var i;
        for (i = 0; i < canvasCount; i++) {
            canvasStack[i].render(timestamp);
        }
        this.trigger('frame', timestamp);
        timerid = window.requestAnimationFrame(this.tick);
    }

    function Timer() {
        this.tick = tick.bind(this);
        this.start();
    }

    extend(Timer, EventEmitter);
    methods(Timer,
        function now() {
            return performance.now();
        },

        function getSeconds() {
            return ~~(this.now() / 1000);
        },

        function bind(canvas) {
            canvasStack.push(canvas);
            canvasCount += 1;
        },

        function start() {
            time = this.now();
            timerid = window.requestAnimationFrame(this.tick);
        },

        function stop() {
            window.cancelAnimationFrame(timerid);
        }
    );

    return new Timer;
})();