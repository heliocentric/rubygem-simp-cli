# vim: set expandtab ts=2 sw=2:
module Simp; end
require_relative 'utils.rb'
require 'pry'
class Simp::Passgen
  def initialize()
    code, @loader_filename = ::Utils.load_code_from_puppet("simplib", ["puppetx/simp//passgen.rb"])
    @passgen = code
  end
  def method_missing(symbol, *args, &block)
    @passgen.send(symbol, *args, &block)
  end
end
