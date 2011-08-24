class TrueClass
  def if_true(then_block)
    then_block.call
  end
  
  def if_false(else_block)
    # do nothing
  end
  
  def if_true_else(then_block, else_block)
    then_block.call
  end
  
  def if_false_else(then_block, else_block)
    else_block.call
  end
end

class FalseClass
  def if_true(then_block)
    # do nothing
  end
  
  def if_false(else_block)
    else_block.call
  end
  
  def if_true_else(then_block, else_block)
    else_block.call
  end
  
  def if_false_else(then_block, else_block)
    then_block.call
  end
end

class NilClass
  def if_true(then_block)
    # do nothing
  end
  
  def if_false(else_block)
    else_block.call
  end
  
  def if_true_else(then_block, else_block)
    else_block.call
  end
  
  def if_false_else(then_block, else_block)
    then_block.call
  end
end

class Array
  def anyone
    if size == 0
      nil
    else
      self[rand(size)]
    end
  end
end

class Object
  def print_on_stdout
    print "#{self}\n"
  end
end
