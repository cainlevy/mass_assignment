module MassAssignment
  def self.included(base)
    base.class_eval do extend ClassMethods end
  end

  def assign(attributes, allowed_attributes = nil, &block)
    return unless attributes
  
    if allowed_attributes
      safe_attributes = filter_attributes(attributes, :only => allowed_attributes)
      yield attributes if block_given?
      self.send("attributes=", safe_attributes, false)
    else
      if policy = self.class.get_mass_assignment_policy
        safe_attributes = filter_attributes(attributes, policy)
        self.send("attributes=", safe_attributes, false)
      else
        # backwards compatibility. use attr_protected and attr_accessible.
        self.attributes = attributes
      end
    end
  end
  
  private

  def filter_attributes(attributes, options = {}) # could surely be refactored.
    attributes = attributes.stringify_keys
  
    if options[:only]
      if options[:only].is_a? Regexp
        attributes.reject { |k, v| !k.gsub(/\(.+/, "").match(options[:only]) }
      elsif options[:only] == :all
        attributes
      else
        whitelist = options[:only].map{|i| i.is_a?(Hash) ? i.keys.first.to_s : i.to_s}
        options[:only].each do |i|
          next unless i.is_a? Hash
          name = i.keys.first.to_s
          next unless attributes[name].is_a? Hash
          attributes[name] = filter_attributes(attributes[name], :only => i.values.first)
        end
        attributes.reject { |k, v| !whitelist.include?(k.gsub(/\(.+/, "")) }
      end
    elsif options[:except]
      if options[:except].is_a? Regexp
        attributes.reject { |k, v| k.gsub(/\(.+/, "").match(options[:except]) }
      elsif options[:except] == :all
        {}
      else
        blacklist = options[:except].map(&:to_s)
        attributes.reject { |k, v| blacklist.include?(k.gsub(/\(.+/, "")) }
      end
    else
      attributes
    end
  end
  
  module ClassMethods
    # sets a default mass assignment policy for your model's attributes. you may choose to start from a
    # closed state that allows no mass assignment, an open state that allows any mass assignment (this is
    # activerecord's default), or somewhere inbetween.
    def mass_assignment_policy(val)
      write_inheritable_attribute :mass_assignment_policy, val
    end
    
    def get_mass_assignment_policy
      read_inheritable_attribute :mass_assignment_policy
    end
  end
end
