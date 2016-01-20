// Object.assign polyfill for IE
if (typeof Object.assign !== 'function') Object.assign = function assign(target) {
    var len = arguments.length, i, key, source;
    if (len < 2) return target;

    for (i = 1; i < len; i++) {
        source = arguments[i];
        if (source == null) continue;
        for (key in source) {
            if (source.hasOwnProperty(key)) target[key] = source[key];
        }
    }

    return target;
};

/**
 * Extends the prototype of `SubClass` by the prototype of the `SuperClass`
 *
 * @param {function} SubClass
 * @param {function} SuperClass
 */
function extend(SubClass, SuperClass) {
    SubClass.prototype = Object.create(SuperClass.prototype, {
        constructor: {
            value: SubClass,
            enumerable: false,
            writable: true,
            configurable: true
        }
    });
}

/**
 * Creates a frozen `defaults` member on the prototype of the `Class`
 * constructor function, extending defaults imported from any superclass.
 *
 * @param {function} Class
 * @param {object} defaults
 */
function defaults(Class, defaults) {
    Object.defineProperty(Class.prototype, 'defaults', {
        enumerable : true,
        value      : Object.freeze(Object.assign({}, Class.prototype.defaults, defaults))
    });
}

/**
 * Assigns named functions passed to this function as extra arguments
 * as methods on the prototype of the constructor function `Class`
 *
 * @param {function} Class
 */
function methods(Class) {
    var len = arguments.length, i, method;
    if (len < 2) return;

    for (i = 0; i < len; i++) {
        method = arguments[i];
        if (typeof method !== 'function' || method.name == null) {
            throw new Error('All `fn` arguments of methods(Class, ...fn) must be named functions!');
        }
        Object.defineProperty(Class.prototype, method.name, {
            enumerable : method.name[0] !== '_',
            value      : method
        });
    }
}