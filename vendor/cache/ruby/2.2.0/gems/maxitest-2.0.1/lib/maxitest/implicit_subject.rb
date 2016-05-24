# this is a bit hacky / overwrites describe, so not included by default ...
module Maxitest
  module ImplicitSubject
    def describe(*args, &block)
      klass = super
      if args.first.is_a?(Class) && !klass.instance_methods(false).include?(:subject)
        klass.let(:subject) { args.first.new }
      end
      klass
    end
  end
end

Object.send(:include, Maxitest::ImplicitSubject) # Minitest hacks Kernel -> we need to use alias method or go into Object
