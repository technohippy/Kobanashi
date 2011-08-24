require 'strscan'
require 'jcode'

module Kobanashi
  class Segment
    attr_reader :line_no, :value
    
    def initialize(line_no, value)
      @line_no = line_no
      @value = value
    end
  end
  
  class Scanner
    def initialize()
      @q = []
      @line = 1
    end
    
    def next_token
      @q.shift || [false, nil]
    end
    
    def scan(str)
      ss = StringScanner.new str
      until (ss.eos?)
        if ss.scan(/\(\^_\^\)\s?＜.*/)       # comment
          # ignore comments
        elsif ss.scan(/;;;.*/)               # comment
          # ignore comments
        elsif ss.scan(/…….*……。/m)       # comment
          # ignore comments
          @line += ss[0].count "\n"
        elsif ss.scan(/#(\\#|\S)/)           # char
          q_push :CHAR, ss[1]
        elsif ss.scan(/[-+]?\d+(?:\.\d+)?/)  # number
          q_push :NUMBER, ss[0]
        elsif ss.scan(/(-|－|マイナス)?[０１２３４５６７８９零一二三四五六七八九十百千万億兆京垓壱弐参伍]+/) # number
          q_push :DNUMBER, ss[0]
        elsif ss.scan(/<<(\S+)>>/)           # constant
          q_push :CONSTANT, ss[1]
        elsif ss.scan(/＜＜(\S+)＞＞/)       # constant
          q_push :CONSTANT, ss[1]
        elsif ss.scan(/<(\S+)>/)             # symbol
          q_push :SYMBOL, ss[1]
        elsif ss.scan(/＜(\S+)＞/)           # symbol
          q_push :SYMBOL, ss[1]
        elsif ss.scan(/『([^』\\]+|\\.)*』/) # string
          @line += ss[0].count "\n"
          q_push :STRING, ss[0][2..-3]
        elsif ss.scan(%r</([^/\\]+|\\.)*/>)  # regular expression
          q_push :REGEXP, ss[0][1..-2]
        elsif ss.scan(/「/)                  # start block
          q_push :START_BLOCK, ss[0]
        elsif ss.scan(/」/)                  # end block
          q_push :END_BLOCK, ss[0]
        elsif ss.scan(/\(/)                  # start block arguments
          q_push :START_BLOCK_ARGS, ss[0]
        elsif ss.scan(/\)/)                  # end block arguments
          q_push :END_BLOCK_ARGS, ss[0]
        elsif ss.scan(/\[/)                  # start array
          q_push :START_ARRAY, ss[0]
        elsif ss.scan(/\]/)                  # end array
          q_push :END_ARRAY, ss[0]
        elsif ss.scan(/・/)                  # array sparator
          q_push :ARRAY_SEPARATOR, ss[0]
        elsif ss.scan(/\{/)                  # start hash
          q_push :START_HASH, ss[0]
        elsif ss.scan(/\}/)                  # end hash
          q_push :END_HASH, ss[0]
        elsif ss.scan(/(:|=>|→)/)           # hash separator
          q_push :HASH_SEPARATOR, ss[0]
        elsif ss.scan(/。/)                  # ku-ten
          q_push :KU_TEN, ss[0]
        elsif ss.scan(/、/)                  # to-ten
          q_push :TO_TEN, ss[0]
        elsif ss.scan(/(<-|←|:=|は\b|を\b)/) # assignment
          q_push :ASSIGN, ss[0]
        elsif ss.scan(/\s+/m)                # white spaces
          @line += ss[0].count "\n"
          # ignore white spaces
        elsif ss.scan(/[^\s\(\)\<\>\[\]\{\}『「、。・→=:]+/)    # literal
          q_push :LITERAL, ss[0]
        else
          File.open('scan.log', 'a') do |f|
            f.write ss.inspect
            f.write "\n"
            f.flush
          end
          raise ss.inspect
        end
      end
      #@q << [:EOS, false]                  # end of string
      @q
    end
    
    def q_push(symbol, value)
      @q << [symbol, Segment.new(@line, value)]
    end
  end
end
