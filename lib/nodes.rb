require 'binding'
require 'koba_ruby_converter'

module Kobanashi
  class Node
    def initialize(value)
      @value = value
    end
    
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      @value
    end
  end
  
  class StatementListNode < Node
    def initialize
      @statement_list = []
    end
    
    def <<(statement)
      @statement_list << statement
    end
    
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      ret = nil
      @statement_list.each do |statement|
        ret = statement.evaluate variable_binding
      end
      ret
    end
  end
  
  class LiteralNode < Node
  end
  
  class BlockNode < Node
    def initialize(args, block)
      @arguments = args.map{|literal_segment| literal_segment.value}
      @block = block
    end
    
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      KobanashiBlock.new @arguments, @block, variable_binding.child_binding
    end
  end
  
  class ArrayNode < Node
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      @value.collect {|e| e.evaluate variable_binding}
    end
  end
  
  class HashNode < Node
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      ret = Hash.new
      @value.each do |k, v|
        ret[k.evaluate(variable_binding)] = v.evaluate variable_binding
      end
      ret
    end
  end
  
  class MessageSendNode < Node
    def initialize(receiver, selector, arguments)
      @receiver = receiver
      @selector = selector
      @arguments = arguments
    end
    
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      receiver = @receiver.evaluate variable_binding
      arguments = @arguments.map {|arg| arg.evaluate variable_binding}
      result = 
      if receiver.is_a?(KobanashiObject) and receiver.respond_to?(@selector)
        receiver.kobanashi_send @selector, *arguments
      else
        selector, add_bind, use_block = KobaRubyConverter.new.to_ruby_method(receiver, @selector)
        if use_block and arguments.last.is_a? KobanashiBlock
          block = arguments.pop
          arguments << variable_binding if add_bind
          receiver.send selector, *arguments do |*arg|
            block.call *arg
          end
        else
          arguments << variable_binding if add_bind
          receiver.send selector, *arguments
        end
      end
      
      variable_binding.it = result
      result
    end
  end
  
  class AssignmentNode < Node
    def initialize(rvalue, lvalue)
      @rvalue = rvalue.value.to_sym
      @lvalue = lvalue
    end
    
    def evaluate(variable_binding=Binding::TopLevelVariableBinding)
      variable_binding.bind @rvalue, @lvalue.evaluate(variable_binding)
    end
  end
  
  class ConstantAssignmentNode < AssignmentNode; end
  class VariableAssignmentNode < AssignmentNode; end
  
  class ReferenceNode < Node
    def initialize(name)
      @name = name.to_sym
    end
    
    def evaluate(binding=Binding::TopLevelVariableBinding)
      binding.evaluate @name
    end
    
    def to_s
      @name.to_s
    end
    
    def to_sym
      @name.to_sym
    end
  end
  
  class ConstantReferenceNode < ReferenceNode
    def evaluate(ignored=nil)
      Binding::TopLevelConstantBinding.evaluate @name
    end
  end
  
  class VariableReferenceNode < ReferenceNode; end
end
