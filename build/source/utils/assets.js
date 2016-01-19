crayon.assets = (function() {
    var store = {};

    return {
        get : function get(url) {
            if (store[url] != null) return store[url];
            return store[url] = new ImageAsset(url);
        },

        define : function define(url, dataurl) {
            return store[url] = new ImageAsset(dataurl);
        },

        preload : function preload(urls, callback) {
            if (typeof urls === 'string') urls = [urls];

            var count = urls.length;

            urls.forEach(function(url) {
                var asset = this.get(url);
                if (asset.__isLoaded) {
                    count -= 1;
                    if (count === 0 && callback != null) callback();
                } else {
                    asset.on('loaded', function() {
                        count -= 1;
                        if (count === 0 && callback != null) callback();
                    });
                }
            }, this);
        }
    }
})();