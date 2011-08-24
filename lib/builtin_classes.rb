class KobanashiObject
  attr_accessor :klass, :instance_binding
  
  def initialize(klass)
    @klass = klass
    @instance_binding = @klass.class_binding.child_binding
    @klass.instance_variable_names.each do |name|
      @instance_binding.bind_local name
    end
    ["私", "わたし", "僕", "ボク", "俺", "オレ"].each do |the_first_person|
      @instance_binding.bind_local the_first_person, self
    end
    ["親", "super", "スーパー"].each do |super_class|
      @instance_binding.bind_local super_class, kobanashi_super
    end
  end
  
  def kobanashi_super
    if @klass.super_class
      KobanashiObject.new @klass.super_class
    else
      nil
    end
  end
  
  def kind_of?(klass)
   @klass == klass
  end
  
  def class_name
    @klass.class_name
  end
  
  def respond_to?(selector)
    if @klass
      @klass.instance_respond_to?(selector) or super(selector)
    else
      false
    end
  end
  
  def kobanashi_send(selector, *arguments)
    method_binding = @instance_binding.child_binding
    method = @klass.instance_method selector
    method.arguments.each_with_index do |arg_name, index|
      method_binding.bind arg_name, arguments[index]
    end
    method.variable_binding = method_binding
    method.call *arguments
  end
end

class KobanashiClass < KobanashiObject
  attr_reader :class_name, :super_class, :instance_variable_names, :class_variable_names, :category, 
              :instance_method_table, :class_method_table, :class_binding
  
  def initialize(class_name=Kobanashi::Binding::ROOT_OBJECT_NAME, super_class=nil, instance_variable_names=[],
                 class_variable_names=[], category=nil)
    @class_name = class_name.to_sym
    @super_class = super_class
    @instance_variable_names = instance_variable_names
    @class_variable_names = class_variable_names
    @category = category.nil? ? nil : category.to_sym
    
    @instance_method_table = Hash.new
    @class_method_table = Hash.new
    @class_binding = (@super_class ? @super_class.class_binding : Kobanashi::Binding::TopLevelVariableBinding).child_binding
    @class_variable_names.each do |name|
      @class_binding.bind_local name
    end
  end
  
  def define_subclass(subclass_name, instance_variable_names="", class_variable_names="", category=nil)
    new_class = KobanashiClass.new subclass_name, self, instance_variable_names.split, class_variable_names.split, category
    Kobanashi::Binding::TopLevelConstantBinding.bind subclass_name, new_class
    new_class
  end
  
  def define_method(name, body, method_table)
    args = []
    name.gsub!(/\s*\((.*?)\)\s*/) do |match|
      args << $1.to_sym
      ""
    end
    body.arguments = args unless args.empty?
    method_table[name] = body
  end
  
  def define_instance_method(name, body)
    define_method name, body, @instance_method_table
  end
  
  def define_class_method(name, body)
    define_method name, body, @class_method_table
  end
  
  def instance_respond_to?(selector)
    if @instance_method_table.include? selector
      true
    elsif @super_class
      @super_class.instance_respond_to? selector
    else
      false
    end
  end
  
  def instance_method(selector)
    if @instance_method_table.include? selector
      @instance_method_table[selector]
    elsif @super_class
      @super_class.instance_method selector
    else
      raise NoMethodError.new(selector)
    end
  end
  
  def new_instance
    KobanashiObject.new self
  end
  
  def ===(obj)
    obj.kind_of? self
  end
  
  def respond_to?(selector)
    @class_method_table.include?(selector) or super(selector)
  end
  
  def kobanashi_send(selector, *arguments)
    method_binding = @class_binding.child_binding
    method = @class_method_table[selector]
    method.arguments.each_with_index do |arg_name, index|
      method_binding.bind arg_name, arguments[index]
    end
    method.variable_binding = method_binding
    method.call *arguments
  end
end

class KobanashiBlock
  attr_accessor :arguments, :variable_binding
  
  def initialize(args, block, variable_binding)
    @arguments = args
    @block = block
    @variable_binding = variable_binding
  end
  
  def call(*args)
    to_proc.call *args
  end
  
  def to_proc
    lambda do
      |*args|
      block_binding = @variable_binding
      args.each_with_index do |arg, index|
        break if @arguments.size <= index
        block_binding.bind @arguments[index], arg
      end
      @block.evaluate block_binding
    end
  end
  
  def if_true(then_block)
    call.if_true then_block
  end
  
  def if_false(else_block)
    call.if_false else_block
  end
  
  def if_true_else(then_block, else_block)
    call.if_true_else then_block, else_block
  end
  
  def if_false_else(then_block, else_block)
    call.if_false_else then_block, else_block
  end
  
  def while_true(block)
    if call
      block.call
      while_true block
    end
  end
  
  def while_false(block)
    unless call
      block.call
      while_false block
    end
  end
end
