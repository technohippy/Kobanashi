class Kobanashi::Parser

rule

  program   : stmt_list

  stmt_list :
                {
                  result = StatementListNode.new
                }
            | stmt_list stmt KU_TEN
                {
                  result << val[1]
                }

  stmt      : literal
            | reference
            | block
            | array
            | hash
            | conjunct_msgsnd
            | msgsnd
            | assign

  literal   : CHAR
                {
                  result = LiteralNode.new val[0].value
                }
            | STRING
                {
                  result = LiteralNode.new val[0].value
                }
            | REGEXP
                {
                  result = LiteralNode.new(Regexp.new(val[0].value))
                }
            | NUMBER
                {
                  result = LiteralNode.new(eval(val[0].value))
                }
            | DNUMBER
                {
                  result = LiteralNode.new val[0].value # TODO
                }
            | SYMBOL
                {
                  result = LiteralNode.new val[0].value.to_sym
                }
            | CONSTANT
                {
                  result = ConstantReferenceNode.new val[0].value
                }
            | LITERAL
                {
                  result = VariableReferenceNode.new val[0].value
                }

  block     : START_BLOCK stmt_list END_BLOCK
                {
                  result = BlockNode.new [], val[1]
                }
            | START_BLOCK block_args stmt_list END_BLOCK
                {
                  result = BlockNode.new val[1], val[2]
                }

  block_args : START_BLOCK_ARGS block_args_elms END_BLOCK_ARGS
                {
                  result = val[1]
                }

  block_args_elms  : 
                       {
                         result = []
                       }
                   | real_block_args_elms

  real_block_args_elms : LITERAL
                           {
                             result = val
                           }
                       | real_block_args_elms ARRAY_SEPARATOR LITERAL
                           {
                             result << val[2]
                           }

  array     : START_ARRAY arr_elms END_ARRAY
                {
                  result = ArrayNode.new val[1]
                }

  arr_elms  : 
                {
                  result = []
                }
            | real_arr_elms

  real_arr_elms : literal
                    {
                      result = val
                    }
                | real_arr_elms ARRAY_SEPARATOR literal
                    {
                      result << val[2]
                    }

  hash      : START_HASH hash_elms END_HASH
                {
                  result = HashNode.new val[1]
                }

  hash_elms :
                {
                  result = Hash.new
                }
            | real_hash_elms

  real_hash_elms : literal HASH_SEPARATOR literal
                    {
                      result = {val[0] => val[2]}
                    }
                 | real_hash_elms ARRAY_SEPARATOR literal HASH_SEPARATOR literal
                    {
                      result[val[2]] = val[4]
                    }

  conjunct_msgsnd : LITERAL TO_TEN msgsnd
                      {
                        result = val[2]
                      }

  msgsnd    : stmt args LITERAL
                {
                  receiver = val[0]
                  arguments = val[1][0]
                  selector = val[1][1].join + val[2].value
                  result = MessageSendNode.new receiver, selector, arguments
                }

  args      :
               {
                 result = [Array.new, Array.new]
               }
            | args LITERAL TO_TEN arg
                {
                  (result ||= [Array.new, Array.new])[0] << val[3]
                  result[1] << (val[1].value + val[2].value)
                }
            | args LITERAL TO_TEN START_BLOCK_ARGS msgsnd END_BLOCK_ARGS
                {
                  (result ||= [Array.new, Array.new])[0] << val[4]
                  result[1] << (val[1].value + val[2].value)
                }

  arg       : literal
            | block

  assign    : CONSTANT ASSIGN stmt
                {
                  rvalue = val[0]
                  lvalue = val[2]
                  result = ConstantAssignmentNode.new rvalue, lvalue
                }
            | LITERAL ASSIGN stmt
                {
                  rvalue = val[0]
                  lvalue = val[2]
                  result = VariableAssignmentNode.new rvalue, lvalue
                }

end

---- header

require 'scan'
require 'nodes'

---- inner

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
