require File.dirname(__FILE__) + '/test_helper'

class User < ActiveRecord::Base
  attr_protected :admin

  class << self
    def columns
      @columns ||= [
        ActiveRecord::ConnectionAdapters::Column.new("name", nil, "varchar(100)", true),
        ActiveRecord::ConnectionAdapters::Column.new("email", nil, "varchar(100)", true),
        ActiveRecord::ConnectionAdapters::Column.new("admin", nil, "tinyint(1)", false)
      ]
    end
  end
end

class MassAssignmentTest < ActiveSupport::TestCase
  def setup
    @user = User.new
    @attributes = {"name" => "Bob", "email" => "bob@example.com"}
    ActiveRecord::Base.logger = stub('debug' => true)
  end

  test "assigning attributes" do
    @user.assign(@attributes)
    assert_equal "Bob", @user.name
    assert_equal "bob@example.com", @user.email
  end
  
  test "assigning protected attributes" do
    @user.assign(@attributes.merge(:admin => true))
    assert_equal "Bob", @user.name
    assert !@user.admin?
  end
  
  test "bypassing protected attributes" do
    @user.assign(@attributes.merge(:admin => true), [:name, :email, :admin])
    assert_equal "Bob", @user.name
    assert @user.admin?
  end
  
  test "assigning unallowed attributes" do
    @user.assign(@attributes.merge(:admin => true), [:name, :email])
    assert_equal "Bob", @user.name
    assert !@user.admin?
  end
end
