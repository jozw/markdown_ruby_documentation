require "markdown_ruby_documentation/version"
require "markdown_ruby_documentation/template_parser"
require "markdown_ruby_documentation/markdown_presenter"
require "markdown_ruby_documentation/generate"
require "markdown_ruby_documentation/git_hub_link"
require "markdown_ruby_documentation/method_linker"
require "markdown_ruby_documentation/method"
require "markdown_ruby_documentation/method/instance_method"
require "markdown_ruby_documentation/method/class_method"
require "markdown_ruby_documentation/html_generator"
require "active_support/core_ext/string"
require "method_source"
require "json"

module MarkdownRubyDocumentation
  START_TOKEN = "=mark_doc".freeze
  END_TOKEN   = "=mark_end".freeze
end
