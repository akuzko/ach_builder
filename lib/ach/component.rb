module ACH
  class Component
    include Validations
    include Constants
    
    class UnknownAttribute < ArgumentError
      def initialize field
        super "Unrecognized attribute '#{field}'"
      end
    end
    
    attr_reader :attributes
    
    def initialize fields = {}, &block
      @attributes = {}
      fields.each do |name, value|
        raise UnknownAttribute.new(name) unless Formatter::RULES.key?(name)
        @attributes[name] = value
      end
      after_initialize if respond_to?(:after_initialize)
      instance_eval(&block) if block
    end
    
    def method_missing meth, *args
      if Formatter::RULES.key?(meth)
        args.empty? ? @attributes[meth] : (@attributes[meth] = args.first)
      else
        super
      end
    end
    
    def before_header
    end
    private :before_header
    
    def header fields = {}, &block
      before_header
      merged_fields = fields_for(self.class::Header).merge(fields)
      @header ||= self.class::Header.new(merged_fields)
      @header.tap do |head|
        head.instance_eval(&block) if block
      end
    end
    
    def control
      klass = self.class::Control
      fields = klass.fields.select{ |f| respond_to?(f) || attributes[f] }
      klass.new Hash[*fields.zip(fields.map{ |f| send(f) }).flatten]
    end
    
    def fields_for component_or_class
      klass = component_or_class.is_a?(Class) ? component_or_class : "ACH::#{component_or_class.camelize}".constantize
      if klass < Component
        attributes
      else
        attrs = attributes.find_all{ |k, v| klass.fields.include?(k) && attributes[k] }
        Hash[*(attrs.flatten)]
      end
    end
    
    def self.has_many plural_name, proc_defaults = nil
      attr_reader plural_name
      
      singular_name = plural_name.to_s.singularize
      klass = "ACH::#{singular_name.camelize}".constantize
      
      define_method(singular_name) do |*args, &block|
        index_or_fields = args.first || {}
        return send(plural_name)[index_or_fields] if Fixnum === index_or_fields
        
        defaults = proc_defaults ? instance_exec(&proc_defaults) : {}
        
        klass.new(fields_for(singular_name).merge(defaults).merge(index_or_fields)).tap do |component|
          component.instance_eval(&block) if block
          send(plural_name) << component
        end
      end
      
      define_method :after_initialize do
        instance_variable_set("@#{plural_name}", [])
      end
    end
  end
end
