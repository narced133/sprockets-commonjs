(function() {
  var modules = {}, cache = {};

  var requireRelative = function(name, root) {
    var path = expand(root, name), indexPath = expand(path, './index'), module, fn;
    module   = cache[path] || cache[indexPath];
    if (module) {
      return module;
    } else if (fn = modules[path] || modules[path = indexPath]) {
      module = {id: path, exports: {}};
      cache[path] = module.exports;
      fn(module.exports, function(name) {
        return require(name, dirname(path));
      }, module);
      return cache[path] = module.exports;
    } else {
      throw 'module ' + name + ' not found';
    }
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    // If path is relative
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part == '..') {
        results.pop();
      } else if (part != '.' && part != '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var require = function(name) {
    return requireRelative(name, '');
  };

  require.define = function(bundle) {
    for (var key in bundle) {
      modules[key] = bundle[key];
    }
  };

  require.modules = modules;
  require.cache   = cache;
  return require;
}).call();
