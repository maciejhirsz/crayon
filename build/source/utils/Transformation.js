var Transformation = (function() {
    function Transformation(options) {
        this.options = Object.assign({}, this.defaults, options);
        if (this.options.from == null) this.options.from = {};
        if (this.options.to == null) this.options.to = {};

        this.finished = false;
        this.startTime = crayon.timer.now() + this.options.delay;
        this.endTime = this.startTime + this.options.duration;
    }

    extend(Transformation, EventEmitter);
    defaults(Transformation, {
        duration   : 1000,
        delay      : 0,
        from       : null,
        to         : null,
        custom     : null,
        transition : 'linear'
    });

    var transitions = {
        linear    : function(stage) {
            return stage;
        },
        easeOut   : function(stage) {
            return Math.sin(stage * Math.PI / 2);
        },
        easeIn    : function(stage) {
            return 1 - Math.sin((1 - stage) * Math.PI / 2);
        },
        easeInOut : function(stage) {
            return (Math.sin((stage * 2 - 1) * Math.PI / 2) + 1) / 2;
        }
    };

    methods(Transformation,
        function isFinished() {
            return this.finished;
        },

        function getStage(time) {
            if (time <= this.startTime) return 0;
            if (time >= this.endTime) return 1;

            var stage      = (time - this.startTime) / this.options.duration,
                transition = transitions[this.options.transition];

            if (typeof transition !== 'function') throw new Error('Unknown transition: ' + this.options.transition);

            return transition(stage);
        },

        function getValue(from, to, stage) {
            // Handle numbers
            if (typeof from === 'number') return (from * (1 - stage)) + (to * stage);

            // Handle colors
            if (from.__isColor) {
                return new Color(
                    this.getValue(from.r, to.r, stage),
                    this.getValue(from.g, to.g, stage),
                    this.getValue(from.b, to.b, stage),
                    this.getValue(from.a, to.a, stage)
                );
            }

            // Fallback
            return to;
        },

        function progress(element, time) {
            if (this.finished) return;
            if (time < this.startTime) return;

            var options = {},
                stage   = this.getStage(time);

            if (typeof this.options.custom === 'function') this.options.custom.call(element, stage);

            var from = this.options.from,
                to   = this.options.to,
                option;

            for (option in to) {
                options[option] = this.getValue(from[option], to[option], stage);
            }

            element.set(options);

            if (time >= this.endTime) {
                this.destroy();
                this.finished = true;
                this.trigger('end');
            }
        },

        function destroy() {
            delete this.options.to;
            delete this.options.from;
        }
    );

    return Transformation;
})();