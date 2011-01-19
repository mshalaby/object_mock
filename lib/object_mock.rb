# A group of methods added to Object class to enable simple mocking 
# of instance or class methods.
# This mocking can be done temporarily within the scope of a block.
# Alternatively it can be done indefinitely until explicitly undone.
 
class Object
 
  # method for mocking or adding methods for a single object 
  # (or class methods if the object is a class instance)
  # methods: a comma separated key value pairs
  # where the key is the name of the instance method to be mocked
  # and the value is the new definition in the form of a proc or lambda
  # or simply the required return for the mocked method
  # An optional block can passed so that the mocking is applied
  # only within the scope of the block
  def mock(methods)
    do_mock(methods)
    if block_given?
      yield
      unmock(*methods.keys)
    end
  end
  
  # method for unmocking methods mocked by mock method
  # methods: a comma separated list of names of instance methods to be unmocked
  # when no methods are passed all mocked instance methods will be unmocked
  # returns: array of the names of methods unmocked
  def unmock(*methods)
    do_unmock(methods)
  end
  
  # The same as mock methods but applies mocking for all instances of the class
  # This method can be either called on the class object or on any instance of the class
  def class_mock(methods, &block)
    return self.class.class_mock(methods, &block) if !self.is_a?(Module)
    do_mock(methods, :instance, lambda {|m| instance_methods.collect{|n| n.to_sym}.include?(m.to_sym)}, self)
 
    if block
      block.call
      class_unmock(*methods.keys)
    end
    
  end
 
  # method for unmocking methods mocked using class_mock
  # This method can be either called on the class object or on any instance of the class
  # methods: a comma separated list of names of instance methods to be unmocked
  # when no methods are passed all mocked instance methods will be unmocked
  # returns: array of the names of methods unmocked
  def class_unmock(*methods)
    return self.class.class_unmock(*methods) if !self.is_a?(Module)
    do_unmock(methods, :instance, self)
  end
  
  private
 
  def do_mock(methods, type = :singleton,
              exists = lambda {|m| singleton_methods.collect{|n| n.to_sym}.include?(m.to_sym)},
              object = (class << self; self; end))
    backup_name = "@#{type.to_s}_backup"
    
    backup = instance_variable_get(backup_name) || {}
  
    methods.each do |name, result|
      backup[name] = backup[name] || []
      
      if exists.call(name)
        original = "#{name}_#{backup[name].length}"
        object.class_eval { alias_method original, name }
      else
        original = nil
      end
      
      backup[name] << original
      t = result.respond_to?(:to_proc) ? result.to_proc : proc { result }
      object.class_eval { define_method(name, t) }
    end
    
    instance_variable_set(backup_name, backup)
  end
 
  def do_unmock(methods, type = :singleton, object = (class << self; self; end))
    unmocked = []
    backup_name = "@#{type.to_s}_backup"
    backup = instance_variable_get(backup_name)
    
    if backup
      methods = backup.keys if methods.empty?
          
      methods.each do |name|
        stack = backup[name]
        if stack
          if stack.last
            object.class_eval do
              alias_method name, stack.last
              remove_method(stack.pop)
            end
          else
            stack.pop
            object.class_eval { remove_method(name) }
          end
          unmocked << name
          backup.delete(name) if stack.empty?
        end
      end
      
      instance_eval { remove_instance_variable(backup_name) } if backup.empty?
    end
    
    return unmocked
  end
 
end

