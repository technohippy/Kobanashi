#http://d.hatena.ne.jp/sumim/20050927/p1 Ruby と Smalltalk のリフレクション機能対応表
#Foo compile: 'foo ^#foo'
#    classified: ClassOrganizer default

$KCODE = 's'
require 'parser'
require 'nodes'
require 'jcode'
require 'core_ext'

module Kobanashi
  class Base
    DOIT = "そうする"
    DOTHAT = "ああする"
    
    def initialize
      @parser = Parser.new self
    end
    
    def interprete(program)
      if program.is_a? File
        program = program.read
      end
      parsed = @parser.parse program
      @variable_table = {}
      @constant_table = {}
      parsed.evaluate
    end
  end
end

def start
  koba = Kobanashi::Base.new
  if ARGV[0]
    File.open(ARGV[0]) do |f|
      koba.interprete f
    end
  else
    puts 'Usage: ruby kobanashi.rb <sourcefile>'
  end
end

start
