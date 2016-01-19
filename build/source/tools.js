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
 * @param {function} Class
 * @param {function} Super
 */
function extend(Class, Super) {
    Object.assign(Class.prototype, Super.prototype);
}

/**
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
 * @param {function} Class
 * @param {...function} methods
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