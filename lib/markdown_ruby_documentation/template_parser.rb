module MarkdownRubyDocumentation
  class TemplateParser

    def initialize(ruby_class, methods)
      @ruby_class = ruby_class
      @methods    = methods
    end

    def to_hash(*args)
      parser
    end

    alias_method :call, :to_hash

    private

    attr_reader :ruby_class, :methods

    def parser
      @parser ||= methods.each_with_object({}) do |meth, h|
        value = parse_erb(strip_comment_hash(extract_dsl_comment_from_method(Method.create("##{meth}"))))
        if value
          h[meth] = value
        end
      end
    end

    module CommentMacros

      # @param [String] str
      # @example
      # @return [String] of any comments proceeding a method def
      def print_raw_comment(str)
        strip_comment_hash(ruby_class_meth_comment(Method.create(str)))
      end

      # @param [String] str
      # @example
      # @return [String]
      def print_mark_doc_from(str)
        parse_erb(extract_dsl_comment(print_raw_comment(str)))
      end

      # @param [String] str
      # @example
      # @return [Object] anything that the evaluated method would return.
      def eval_method(str)
        case (method = Method.create(str))
        when ClassMethod
          get_context_class(method).public_send(method.name)
        when InstanceMethod
          eval(print_method_source(method.method_reference))
        end
      end

      # @param [String] input
      # @return [String] the source of a method block is returned as text.
      def print_method_source(input)
        method = Method.create(input.dup)
        get_context_class(method)
          .public_send(method.type, method.name)
          .source
          .split("\n")[1..-2]
          .map(&:lstrip)
          .join("\n")
      end

      def git_hub_method_url(input)
        method = Method.create(input.dup)
        GitHubLink::MethodUrl.new(subject: get_context_class(method), method_object: method)
      end

      def git_hub_file_url(file_path)
        GitHubLink::FileUrl.new(file_path: file_path)
      end

      def pretty_code(source_code)
        source_code.gsub(/["']?[a-z_A-Z?0-9]*["']?/) do |s|
          if s.include?("_") && !(/["'][a-z_A-Z?0-9]*["']/ =~ s)
            "'#{s.humanize}'"
          else
            s.humanize
          end
        end.gsub(":", '')

      end

      private

      def parse_erb(str)
        ruby_class.module_eval(<<-RUBY, __FILE__, __LINE__+1)
        def self.get_binding
          self.send(:binding)
        end
        RUBY
        ruby_class.extend(CommentMacros)
        ERB.new(str, nil, "-").result(ruby_class.get_binding)
      end

      def strip_comment_hash(str)
        str.gsub(/^#[\s]?/, "")
      end

      def ruby_class_meth_comment(method)
        get_context_class(method).public_send(method.type, method.name).comment
      end

      def extract_dsl_comment(comment_string)
        if (v = when_start_and_end(comment_string))
          v
        elsif (x = when_only_start(comment_string))
          x << "[//]: # (This method has no mark_end)"
        else
          ""
        end
      end

      def when_start_and_end(comment_string)
        v = /#{START_TOKEN}\n((.|\n)*)#{END_TOKEN}/.match(comment_string)
        v.try!(:captures).try!(:first)
      end

      def when_only_start(comment_string)
        v = /#{START_TOKEN}\n((.|\n)*)/.match(comment_string)
        v.try!(:captures).try!(:first)
      end

      def extract_dsl_comment_from_method(method)
        extract_dsl_comment strip_comment_hash(ruby_class_meth_comment(method))
      end

      def ruby_class
        @ruby_class || self
      end

      def get_context_class(method)
        if method.context == :ruby_class
          ruby_class
        else
          method.context.to_s.constantize
        end
      end
    end
    include CommentMacros
  end
end
