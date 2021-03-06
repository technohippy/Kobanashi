#
# DO NOT MODIFY!!!!
# This file is automatically generated by racc 1.4.5
# from racc grammer file "lib/parser.yy".
#

require 'racc/parser'



require 'scan'
require 'nodes'


module Kobanashi

  class Parser < Racc::Parser

module_eval <<'..end lib/parser.yy modeval..id451943ca5c', 'lib/parser.yy', 179

def initialize(interpreter)
  @yydebug = true
  @interpreter = interpreter
end

def parse(str)
  @scanner = Scanner.new
  @scanner.scan str
  do_parse
end

def next_token
  @scanner.next_token
end

#def on_error(t, val, vstack)
#  raise Racc:ParseError, "\nunexpected token #{val.inspect}"
#end
..end lib/parser.yy modeval..id451943ca5c

##### racc 1.4.5 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 1, 25, :_reduce_none,
 0, 26, :_reduce_2,
 3, 26, :_reduce_3,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 27, :_reduce_none,
 1, 28, :_reduce_12,
 1, 28, :_reduce_13,
 1, 28, :_reduce_14,
 1, 28, :_reduce_15,
 1, 28, :_reduce_16,
 1, 28, :_reduce_17,
 1, 28, :_reduce_18,
 1, 28, :_reduce_19,
 3, 29, :_reduce_20,
 4, 29, :_reduce_21,
 3, 35, :_reduce_22,
 0, 36, :_reduce_23,
 1, 36, :_reduce_none,
 1, 37, :_reduce_25,
 3, 37, :_reduce_26,
 3, 30, :_reduce_27,
 0, 38, :_reduce_28,
 1, 38, :_reduce_none,
 1, 39, :_reduce_30,
 3, 39, :_reduce_31,
 3, 31, :_reduce_32,
 0, 40, :_reduce_33,
 1, 40, :_reduce_none,
 3, 41, :_reduce_35,
 5, 41, :_reduce_36,
 3, 32, :_reduce_37,
 3, 33, :_reduce_38,
 0, 42, :_reduce_39,
 4, 42, :_reduce_40,
 6, 42, :_reduce_41,
 1, 43, :_reduce_none,
 1, 43, :_reduce_none,
 3, 34, :_reduce_44,
 3, 34, :_reduce_45 ]

racc_reduce_n = 46

racc_shift_n = 72

racc_action_table = [
     8,     9,    10,    13,    15,    18,    20,    22,     4,     6,
    25,    26,    54,    52,    12,    53,    17,     8,     9,    10,
    13,    15,    18,    20,    22,     4,     6,    56,    51,    50,
   -37,    12,   -45,    17,     8,     9,    10,    13,    15,    18,
    20,    22,     4,     6,    49,    57,    58,    59,    12,    45,
    17,     8,     9,    10,    13,    15,    18,    20,    22,     4,
     6,    48,    40,    30,   -44,    12,    63,    17,     8,     9,
    10,    13,    15,    18,    20,    22,     4,     6,    28,    68,
    24,     3,    12,    71,    17,     8,     9,    10,    13,    15,
    18,    20,    22,     4,     6,   nil,   nil,   nil,   nil,    12,
   nil,    17,     8,     9,    10,    13,    15,    18,    20,    22,
     4,     6,   nil,   nil,   nil,   nil,    12,   nil,    17,     9,
    10,    13,    15,    18,    20,    36,    32,     6,   nil,    64,
     9,    10,    13,    15,    18,    20,    36,    32,     9,    10,
    13,    15,    18,    20,    36,    32,     9,    10,    13,    15,
    18,    20,    36,    32,     9,    10,    13,    15,    18,    20,
    36,    32,     9,    10,    13,    15,    18,    20,    36,    32,
     9,    10,    13,    15,    18,    20,    36,    32 ]

racc_action_check = [
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     4,     4,    39,    37,     2,    38,     2,    44,    44,    44,
    44,    44,    44,    44,    44,    44,    44,    44,    35,    33,
    41,    44,    43,    44,    64,    64,    64,    64,    64,    64,
    64,    64,    64,    64,    31,    46,    47,    49,    64,    28,
    64,    29,    29,    29,    29,    29,    29,    29,    29,    29,
    29,    29,    22,    11,    55,    29,    58,    29,    26,    26,
    26,    26,    26,    26,    26,    26,    26,    26,     6,    62,
     3,     1,    26,    69,    26,    25,    25,    25,    25,    25,
    25,    25,    25,    25,    25,   nil,   nil,   nil,   nil,    25,
   nil,    25,    40,    40,    40,    40,    40,    40,    40,    40,
    40,    40,   nil,   nil,   nil,   nil,    40,   nil,    40,    59,
    59,    59,    59,    59,    59,    59,    59,    59,   nil,    59,
    51,    51,    51,    51,    51,    51,    51,    51,    54,    54,
    54,    54,    54,    54,    54,    54,    12,    12,    12,    12,
    12,    12,    12,    12,    52,    52,    52,    52,    52,    52,
    52,    52,    68,    68,    68,    68,    68,    68,    68,    68,
    17,    17,    17,    17,    17,    17,    17,    17 ]

racc_action_pointer = [
   nil,    81,    -3,    80,   -12,   nil,    64,   nil,   nil,   nil,
   nil,    61,   142,   nil,   nil,   nil,   nil,   166,   nil,   nil,
   nil,   nil,    39,   nil,   nil,    82,    65,   nil,    38,    48,
   nil,    33,   nil,    11,   nil,    12,   nil,    -8,    -5,    -4,
    99,    28,   nil,    30,    14,   nil,    30,    30,   nil,    25,
   nil,   126,   150,   nil,   134,    62,   nil,   nil,    55,   115,
   nil,   nil,    58,   nil,    31,   nil,   nil,   nil,   158,    68,
   nil,   nil ]

racc_action_default = [
    -2,   -46,    -1,   -46,   -19,   -10,    -2,   -11,    -5,   -12,
   -13,   -39,   -28,   -14,    -4,   -15,    -6,   -33,   -16,    -7,
   -17,    -8,   -18,    -9,    72,   -46,   -46,    -2,   -23,   -46,
    -3,   -46,   -19,   -46,   -30,   -29,   -18,   -46,   -46,   -34,
   -46,   -10,   -39,   -39,   -46,   -25,   -46,   -24,   -20,   -38,
   -27,   -46,   -46,   -32,   -46,   -39,   -21,   -22,   -46,   -46,
   -31,   -35,   -46,   -26,   -46,   -42,   -43,   -40,   -46,   -10,
   -36,   -41 ]

racc_goto_table = [
    34,    46,    41,     2,     1,    37,    42,    43,    27,    29,
    66,    47,    33,    35,    38,    39,    67,   nil,   nil,   nil,
   nil,    55,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    44,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    60,
    61,    69,    62,   nil,   nil,    42,   nil,    65,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    70 ]

racc_goto_check = [
     4,    12,     9,     2,     1,     4,     3,     3,    11,     2,
     5,    13,    14,    15,    16,    17,    19,   nil,   nil,   nil,
   nil,     3,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
     2,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     4,
     4,     9,     4,   nil,   nil,     3,   nil,     4,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     4 ]

racc_goto_pointer = [
   nil,     4,     3,   -19,   -12,   -49,   nil,   nil,   nil,   -23,
   nil,     2,   -27,   -17,     0,     1,    -3,    -2,   nil,   -43 ]

racc_goto_default = [
   nil,   nil,   nil,    11,    14,    16,    19,    21,    23,     5,
     7,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    31,   nil ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :KU_TEN => 2,
 :reference => 3,
 :CHAR => 4,
 :STRING => 5,
 :REGEXP => 6,
 :NUMBER => 7,
 :DNUMBER => 8,
 :SYMBOL => 9,
 :CONSTANT => 10,
 :LITERAL => 11,
 :START_BLOCK => 12,
 :END_BLOCK => 13,
 :START_BLOCK_ARGS => 14,
 :END_BLOCK_ARGS => 15,
 :ARRAY_SEPARATOR => 16,
 :START_ARRAY => 17,
 :END_ARRAY => 18,
 :START_HASH => 19,
 :END_HASH => 20,
 :HASH_SEPARATOR => 21,
 :TO_TEN => 22,
 :ASSIGN => 23 }

racc_use_result_var = true

racc_nt_base = 24

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'KU_TEN',
'reference',
'CHAR',
'STRING',
'REGEXP',
'NUMBER',
'DNUMBER',
'SYMBOL',
'CONSTANT',
'LITERAL',
'START_BLOCK',
'END_BLOCK',
'START_BLOCK_ARGS',
'END_BLOCK_ARGS',
'ARRAY_SEPARATOR',
'START_ARRAY',
'END_ARRAY',
'START_HASH',
'END_HASH',
'HASH_SEPARATOR',
'TO_TEN',
'ASSIGN',
'$start',
'program',
'stmt_list',
'stmt',
'literal',
'block',
'array',
'hash',
'conjunct_msgsnd',
'msgsnd',
'assign',
'block_args',
'block_args_elms',
'real_block_args_elms',
'arr_elms',
'real_arr_elms',
'hash_elms',
'real_hash_elms',
'args',
'arg']

Racc_debug_parser = false

##### racc system variables end #####

 # reduce 0 omitted

 # reduce 1 omitted

module_eval <<'.,.,', 'lib/parser.yy', 10
  def _reduce_2( val, _values, result )
                  result = StatementListNode.new
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 14
  def _reduce_3( val, _values, result )
                  result << val[1]
   result
  end
.,.,

 # reduce 4 omitted

 # reduce 5 omitted

 # reduce 6 omitted

 # reduce 7 omitted

 # reduce 8 omitted

 # reduce 9 omitted

 # reduce 10 omitted

 # reduce 11 omitted

module_eval <<'.,.,', 'lib/parser.yy', 28
  def _reduce_12( val, _values, result )
                  result = LiteralNode.new val[0].value
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 32
  def _reduce_13( val, _values, result )
                  result = LiteralNode.new val[0].value
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 36
  def _reduce_14( val, _values, result )
                  result = LiteralNode.new(Regexp.new(val[0].value))
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 40
  def _reduce_15( val, _values, result )
                  result = LiteralNode.new(eval(val[0].value))
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 44
  def _reduce_16( val, _values, result )
                  result = LiteralNode.new val[0].value # TODO
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 48
  def _reduce_17( val, _values, result )
                  result = LiteralNode.new val[0].value.to_sym
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 52
  def _reduce_18( val, _values, result )
                  result = ConstantReferenceNode.new val[0].value
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 56
  def _reduce_19( val, _values, result )
                  result = VariableReferenceNode.new val[0].value
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 61
  def _reduce_20( val, _values, result )
                  result = BlockNode.new [], val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 65
  def _reduce_21( val, _values, result )
                  result = BlockNode.new val[1], val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 70
  def _reduce_22( val, _values, result )
                  result = val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 75
  def _reduce_23( val, _values, result )
                         result = []
   result
  end
.,.,

 # reduce 24 omitted

module_eval <<'.,.,', 'lib/parser.yy', 81
  def _reduce_25( val, _values, result )
                             result = val
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 85
  def _reduce_26( val, _values, result )
                             result << val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 90
  def _reduce_27( val, _values, result )
                  result = ArrayNode.new val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 95
  def _reduce_28( val, _values, result )
                  result = []
   result
  end
.,.,

 # reduce 29 omitted

module_eval <<'.,.,', 'lib/parser.yy', 101
  def _reduce_30( val, _values, result )
                      result = val
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 105
  def _reduce_31( val, _values, result )
                      result << val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 110
  def _reduce_32( val, _values, result )
                  result = HashNode.new val[1]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 115
  def _reduce_33( val, _values, result )
                  result = Hash.new
   result
  end
.,.,

 # reduce 34 omitted

module_eval <<'.,.,', 'lib/parser.yy', 121
  def _reduce_35( val, _values, result )
                      result = {val[0] => val[2]}
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 125
  def _reduce_36( val, _values, result )
                      result[val[2]] = val[4]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 130
  def _reduce_37( val, _values, result )
                        result = val[2]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 138
  def _reduce_38( val, _values, result )
                  receiver = val[0]
                  arguments = val[1][0]
                  selector = val[1][1].join + val[2].value
                  result = MessageSendNode.new receiver, selector, arguments
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 143
  def _reduce_39( val, _values, result )
                 result = [Array.new, Array.new]
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 148
  def _reduce_40( val, _values, result )
                  (result ||= [Array.new, Array.new])[0] << val[3]
                  result[1] << (val[1].value + val[2].value)
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 153
  def _reduce_41( val, _values, result )
                  (result ||= [Array.new, Array.new])[0] << val[4]
                  result[1] << (val[1].value + val[2].value)
   result
  end
.,.,

 # reduce 42 omitted

 # reduce 43 omitted

module_eval <<'.,.,', 'lib/parser.yy', 163
  def _reduce_44( val, _values, result )
                  rvalue = val[0]
                  lvalue = val[2]
                  result = ConstantAssignmentNode.new rvalue, lvalue
   result
  end
.,.,

module_eval <<'.,.,', 'lib/parser.yy', 169
  def _reduce_45( val, _values, result )
                  rvalue = val[0]
                  lvalue = val[2]
                  result = VariableAssignmentNode.new rvalue, lvalue
   result
  end
.,.,

 def _reduce_none( val, _values, result )
  result
 end

  end   # class Parser

end   # module Kobanashi
