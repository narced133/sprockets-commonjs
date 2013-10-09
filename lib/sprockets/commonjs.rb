require 'sprockets'
require 'tilt'

module Sprockets
  class CommonJS < Tilt::Template
    LIB_WRAPPER = <<EOF
(function(){
  var namespace = "%s".split("."),
      name = namespace[namespace.length - 1],
      base = this,
      i;
  for(i=0; i < namespace.length-1; i++){
    base = (base[namespace[i]] = base[namespace[i]] || {});
  }
  if(base[name] === undefined) {
    base[name] = %s
  }
})();
EOF

    MODULE_WRAPPER = '%s.define({%s:' +
                     'function(exports, require, module){' +
                     '%s' +
                     ";}});\n"

    EXTENSIONS = %w{.module .cjs}

    class << self
      attr_accessor :default_namespace
    end

    self.default_mime_type = 'application/javascript'
    self.default_namespace = 'require'

    protected

    def prepare
      @namespace = self.class.default_namespace
    end

    def evaluate(scope, locals, &block)
      if commonjs_module?(scope)
        scope.require_asset 'sprockets/commonjs'
        MODULE_WRAPPER % [ namespace, module_name(scope), data ]
      elsif commonjs_lib?(scope)
        LIB_WRAPPER % [ namespace, data ]
      else
        data
      end
    end

    private

    attr_reader :namespace

    def commonjs_module?(scope)
      EXTENSIONS.include?(File.extname(scope.logical_path))
    end

    def commonjs_lib?(scope)
      scope.logical_path == 'sprockets/commonjs'
    end

    def module_name(scope)
      scope.logical_path.
        gsub(/^\.?\//, ''). # Remove relative paths
        chomp('.module').   # Remove module ext
        inspect
    end

  end

  register_postprocessor 'application/javascript', CommonJS
  append_path File.expand_path('../../../assets', __FILE__)
end
