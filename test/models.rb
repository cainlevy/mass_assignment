class User < ActiveRecord::Base
  class << self
    def columns
      @columns ||= [
        ActiveRecord::ConnectionAdapters::Column.new("name", nil, "varchar(100)", true),
        ActiveRecord::ConnectionAdapters::Column.new("email", nil, "varchar(100)", true),
        ActiveRecord::ConnectionAdapters::Column.new("role_id", nil, "integer(11)", false)
      ]
    end

    def column_defaults
      columns.inject({}) { |h, col| h.merge(col.name => col.default) }
    end

    def columns_hash
      columns.inject({}) { |h, col| h.merge(col.name => col) }
    end

    def primary_key
      'id'
    end

    def attributes_protected_by_default
      [ primary_key ]
    end
  end

  def friend
    @friend ||= User.new
  end

  def friend_attributes=(attributes)
    friend.attributes = attributes
  end
end

class ProtectedUser < User
  attr_protected :role_id
end

class ClosedUser < User
  mass_assignment_policy :except => :all
end

class SemiClosedUser < User
  mass_assignment_policy :except => /_id$/
end

class OpenUser < User
  mass_assignment_policy :only => :all
end
