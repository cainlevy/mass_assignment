module MassAssignment
  def self.included(base)
    base.class_eval do
      class_attribute :assignment_policy, :instance_reader => false, :instance_writer => false
      def self.mass_assignment_policy(val)
        self.assignment_policy = val
      end
    end
  end

  # Basic Example:
  #
  #   @user = User.new
  #   @user.assign(params[:user], [:username, :email, :password, :password_confirmation])
  #   @user.save!
  #
  # Nested Assignment:
  #
  #   @user = User.find_by_id(params[:id])
  #   @user.assign(params[:user], [:username, :email, {:dog_attributes => [:id, :_destroy, :name, :color]}])
  #   @user.save!
  #
  # Deep Assignment:
  #
  #   @user = User.find_by_id(params[:id])
  #   @user.assign(params[:user], [:username, :email]) do |user_params|
  #     @user.dog.assign(user_params[:dog], [:name, :color])
  #   end
  #   @user.save!
  def assign(attributes, allowed_attributes = nil, &block)
    return unless attributes and attributes.is_a? Hash

    if allowed_attributes
      safe_attributes = filter_attributes(attributes, :only => allowed_attributes)
      yield attributes if block_given?
      mass_assign_safe_attributes(safe_attributes)
    else
      if policy = self.class.assignment_policy
        safe_attributes = filter_attributes(attributes, policy)
        mass_assign_safe_attributes(safe_attributes)
      else
        # fall back on Rails' system
        self.attributes = attributes
      end
    end
  end

  private

  def mass_assign_safe_attributes(safe_attributes)
    if respond_to?(:assign_attributes)
      assign_attributes(safe_attributes, :without_protection => true)
    else
      self.send("attributes=", safe_attributes, false)
    end
  end

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
end

ActiveRecord::Base.class_eval do include MassAssignment end
