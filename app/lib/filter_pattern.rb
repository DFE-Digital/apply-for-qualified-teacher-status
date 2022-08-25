# frozen_string_literal: true

module FilterPattern
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval { private_class_method(:new) }
  end

  def apply
    raise(NotImplementedError("#apply must be implemented"))
  end

  module ClassMethods
    def apply(**args)
      return new.apply if args.empty?

      new(**args).apply
    end
  end
end
