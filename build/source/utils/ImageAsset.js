var ImageAsset = crayon.ImageAsset = (function () {
    function ImageAsset(url) {
        this.__isAsset = true;
        this.__isLoaded = false;
        this._width = 0;
        this._height = 0;

        var image = new Image;
        image.src = url;
        image.onload = (function() {
            var width = this._width = image.naturalWidth,
                height = this._height = image.naturalHeight;

            this._cache = new Canvas({
                width: width,
                height: height,
                'static': true
            });

            this._cache.drawRaw(image, 0, 0, width, height);
            this._image = this._cache.getDocumentElement();
            this.__isLoaded = true;
            this.trigger('loaded');

            // loaded happens only once
            this.off('loaded');
            delete image.onload;
        }).bind(this);
    }

    extend(ImageAsset, EventEmitter);
    methods(ImageAsset,
        function getPixelAlpha(x, y) {
            return this._cache.getPixelAlpha(x, y);
        },

        function getDocumentElement() {
            if (this.__isLoaded) return this._image;
            return null;
        }
    );

    return ImageAsset;
})();