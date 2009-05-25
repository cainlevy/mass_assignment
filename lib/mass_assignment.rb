module MassAssignment
  def assign(new_attributes, allowed_attributes = nil)
    if allowed_attributes
      attributes = new_attributes.stringify_keys if new_attributes
      allowed_attributes = allowed_attributes.map(&:to_s)
      
      # filter
      safe_attributes = attributes.reject { |k, v| !allowed_attributes.include?(k.gsub(/\(.+/, "")) }
      
      # assign
      self.send("attributes=", safe_attributes, false) # assign w/o attr_protected/attr_accessible
    else
      self.attributes = new_attributes
    end
  end
end
