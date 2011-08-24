require 'yaml'

module Kobanashi
  class KobaRubyConverter
    METHOD_CONVERTER_FILE = 'method_convert.yml'

    def initialize(filename = METHOD_CONVERTER_FILE)
      @filename = filename
      #rewrite_method_missing
    end

=begin
    def rewrite_method_missing
      convert_table.each do |class_vs_methods|
        klass_name = class_vs_methods.keys[0]
        klass = eval(klass_name)
        methods = class_vs_methods[klass_name]
        
        unless klass.is_a? KobanashiObject
        klass.class_eval <<-end_eval
          def method_missing(name, *args)
            case name
            #{methods.collect{|method_info| compare_expression(method_info, "self.send #{method_info['ruby'].inspect}, *args")}.join("\n")}
            else
              super
            end
          end
        end_eval
        end

        unless klass.is_a? KobanashiObject
          klass.class_eval <<-end_eval
            def respond_to?(name)
              case name
              #{methods.collect{|method_info| compare_expression(method_info, "true")}.join("\n")}
              else
                super
              end
            end
          end_eval
        end
      end
    end
  
    def compare_expression(method_info, exp)
      if method_info['key_type'] == 'Regexp'
        re = method_info['kobanashi']
        re.insert(0, '^') unless re[0] == ?^
        re.concat('$') unless re[-1] == ?$
        "when /#{re}/
        #{exp}"
      else
        "when #{method_info['kobanashi'].to_sym.inspect}
        #{exp}"
      end
    end
=end

    def convert_table
      @convert_table ||= YAML.load(File.read(@filename))
    end
    
    def to_ruby_method(receiver, selector)
      convert_table.each do |class_vs_methods|
        class_name = class_vs_methods.keys[0]
        klass = eval class_name
        if receiver.is_a? klass
          methods = class_vs_methods[class_name]
          methods.each do |method_info|
            if method_info['key_type'] == 'Regexp'
              re = method_info['kobanashi']
              re.insert(0, '^') unless re[0] == ?^
              re.concat('$') unless re[-1] == ?$
              if Regexp.new(re) =~ selector.to_s
                return method_info['ruby'], method_info['add_bind'] == true, method_info['use_block'] == true
              end
            else
              if method_info['kobanashi'] == selector.to_s
                return method_info['ruby'], method_info['add_bind'] == true, method_info['use_block'] == true
              end
            end
          end
        end
      end
      #raise "failed to interprete:\n*receiver*: #{receiver.inspect}\n*selector*: #{selector.inspect}"
      raise "failed to interprete:\nreceiver: #{receiver.class.name}\nselector: #{selector.to_s}"
    end
  end
end
