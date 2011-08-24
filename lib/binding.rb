require 'builtin_classes'

module Kobanashi
  class Binding
    class NullBinding < Binding
      def initialize
      end
      
      def target_reference_table(key)
        nil
      end
      
      def evaluate(key)
        nil
      end
    end
    
    ROOT_OBJECT_NAME = "もの".to_sym
    TRUE_CONSTANT_NAME = "本当".to_sym
    FALSE_CONSTANT_NAME = "誤り".to_sym
    KOBANASHI_STDIN = "キーボード".to_sym
    
    DEMONSTRATIVE_PRODOUN_RESULT = "結果".to_sym
    DEMONSTRATIVE_PRODOUN_IT = "それ".to_sym
    DEMONSTRATIVE_PRODOUN_THAT = "あれ".to_sym
    
    attr :reference_table
    attr_accessor :parent_binding
    
    def initialize
      @parent_binding = NullBinding.new
    end
    
    def child_binding
      binding = Binding.new
      binding.parent_binding = self
      binding
    end
    
    def it=(obj)
      reference_table[DEMONSTRATIVE_PRODOUN_THAT], reference_table[DEMONSTRATIVE_PRODOUN_IT] = reference_table[DEMONSTRATIVE_PRODOUN_IT], obj
      reference_table[DEMONSTRATIVE_PRODOUN_RESULT] = reference_table[DEMONSTRATIVE_PRODOUN_IT]
    end
    
    def bind_local(key, value=nil)
      reference_table[key.to_sym] = value
    end
    
    def bind(key, value=nil)
      key = key.to_sym
      target_reference_table(key)[key] = value
    end
    
    def target_reference_table(key)
      if reference_table.include? key
        reference_table
      else
        parent_binding.target_reference_table(key) || reference_table
      end
    end
    
    def evaluate(key)
      evaluated = reference_table[key.to_sym]
      evaluated.nil? ? @parent_binding.evaluate(key) : evaluated
      #reference_table[key.to_sym] || @parent_binding.evaluate(key)
    end
    
    def reference_table
      @reference_table ||= Hash.new
    end
    
    def undef_all_references
      @reference_table = Hash.new
    end
    
    private
      def self.top_level_variable_binding
        ret = self.new
        ret
      end
      
      def self.top_level_constant_binding
        ret = self.new
        ret.bind ROOT_OBJECT_NAME, KobanashiClass.new
        ret.bind TRUE_CONSTANT_NAME, true
        ret.bind FALSE_CONSTANT_NAME, false
        ret.bind KOBANASHI_STDIN, STDIN
        ret
      end
    public
    
    TopLevelVariableBinding = top_level_variable_binding
    TopLevelConstantBinding = top_level_constant_binding
  end
end
