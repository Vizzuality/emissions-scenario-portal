require 'active_support/concern'

module Sanitizer
  extend ActiveSupport::Concern

  class_methods do
    def sanitise_positive_integer(i, default = nil)
      new_i =
        if i.is_a?(String)
          tmp = i.to_i
          tmp.to_s == i ? tmp : nil
        else
          i
        end
      new_i && new_i.positive? ? new_i : default
    end
  end
end
