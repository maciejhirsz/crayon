/**
 * @author Maciej Hirsz
 *
 * crayon may be freely distributed under the MIT license.
*/

(function() {
    'use strict';

    var crayon = {};

    /** @include {tools.js} */
    /** @include {utils/EventEmitter.js} */
    /** @include {utils/timer.js} */
    /** @include {utils/Color.js} */
    /** @include {utils/Point.js} */
    /** @include {utils/RelativePoint.js} */
    /** @include {utils/MappedPoint.js} */
    /** @include {utils/Transformation.js} */
    /** @include {utils/ImageAsset.js} */
    /** @include {utils/assets.js} */
    /** @include {utils/filters.js} */
    /** @include {elements/Element.js} */
    /** @include {elements/Sprite.js} */
    /** @include {elements/Shape.js} */
    /** @include {elements/Text.js} */
    /** @include {elements/Rectangle.js} */
    /** @include {elements/Circle.js} */
    /** @include {elements/Ellipse.js} */
    /** @include {elements/CustomShape.js} */
    /** @include {Canvas.js} */

    if (typeof define === 'function' && define.amd) {
        define(function() {
            return crayon
        });
    } else if (typeof exports !== 'undefined') {
        module.exports = crayon;
    } else {
        this.crayon = crayon;
    }
}).call(window);