module MarkdownRubyDocumentation
  class NullMethod < Method

    def self.type_symbol
      ""
    end

    def name
      nil
    end

    def type
      raise "Does not have a type"
    end

    def to_proc
      raise "Not convertible to a proc"
    end

    def context
      method_reference.to_sym
    end

  end
end
