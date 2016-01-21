var Color = crayon.Color = (function() {
    var rgbaPattern = /\s*rgba\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d+.?\d*|\d*.?\d+)s*\)\s*/i;

    function Color(r, g, b, a) {
        this.__isColor = true;
        if (typeof r === 'string') {
            var hash, matches;
            if (r[0] === '#') {
                hash = r;
                if (hash.length === 7) {
                    r = parseInt(hash.slice(1, 3), 16);
                    g = parseInt(hash.slice(3, 5), 16);
                    b = parseInt(hash.slice(5, 7), 16);
                } else if (hash.length === 4) {
                    r = parseInt(hash[1] + hash[1], 16);
                    g = parseInt(hash[2] + hash[2], 16);
                    b = parseInt(hash[3] + hash[3], 16);
                } else {
                    throw new Error('Invalid color string: ' + hash);
                }
            } else if (matches = r.match(rgbaPattern)) {
                r = Number(matches[1]);
                g = Number(matches[2]);
                b = Number(matches[3]);
                a = parseFloat(matches[4]);
                if (Number.isNaN(a)) a = 1;
            } else {
                throw new Error('Invalid color string: ' + r);
            }
        }
        this.set(r, g, b, a);
    }

    methods(Color,
        function set(r, g, b, a) {
            // Tilde is way more performant than Math.floor
            this.r = ~~r;
            this.g = ~~g;
            this.b = ~~b;
            this.a = (a != null) ? a : 1;
            this.cacheString();
        },

        function cacheString() {
            this.string = 'rgba(' + this.r + ',' + this.g + ',' + this.b + ',' + this.a + ')';
        },

        function toString() {
            return this.string;
        }
    );

    return Color;
})();

