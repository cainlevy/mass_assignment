require File.dirname(__FILE__) + '/test_helper'

class MassAssignmentTest < ActiveSupport::TestCase
  def setup
    @user = ProtectedUser.new
    @attributes = {"name" => "Bob", "email" => "bob@example.com"}
    ActiveRecord::Base.logger = stub('debug' => true)
  end

  test "assigning nothing" do
    params = {}
    assert_nothing_raised do
      @user.assign(params[:user])
    end
  end

  test "assigning a string" do
    params = {:user => "well this is embarrassing"}
    assert_nothing_raised do
      @user.assign(params[:user])
    end
  end

  test "assigning attributes" do
    @user.assign(@attributes)
    assert_equal "Bob", @user.name
    assert_equal "bob@example.com", @user.email
  end

  test "assigning protected attributes" do
    @user.assign(@attributes.merge(:role_id => 1))
    assert_equal "Bob", @user.name
    assert_nil @user.role_id
  end

  test "overriding protected attributes" do
    @user.assign(@attributes.merge(:role_id => 1), [:name, :email, :role_id])
    assert_equal "Bob", @user.name
    assert_equal 1, @user.role_id
  end

  test "assigning unallowed attributes" do
    @user.assign(@attributes.merge(:role_id => 1), [:name, :email])
    assert_equal "Bob", @user.name
    assert_nil @user.role_id
  end

  test "nested assignment" do
    @user.assign(@attributes.merge(:friend_attributes => {:name => 'Joe', :role_id => 1}), [:name, :role_id, {:friend_attributes => [:name]}])
    assert_equal "Joe", @user.friend.name
    assert_nil @user.friend.role_id
  end

  test "deep assignment" do
    @user.assign(@attributes.merge(:friend => {:name => 'Joe', :role_id => 1}), [:name, :role_id]) do |params|
      @user.friend.assign(params[:friend], [:name])
    end
    assert_equal "Joe", @user.friend.name
    assert_nil @user.friend.role_id
  end
end

class MassAssignmentPolicyTest < ActiveSupport::TestCase
  def setup
    @attributes = {"name" => "Bob", "role_id" => 1}
    ActiveRecord::Base.logger = stub('debug' => true)
  end

  test "an open policy" do
    @user = OpenUser.new
    @user.assign(@attributes)
    assert_equal "Bob", @user.name
    assert_equal 1, @user.role_id
  end

  test "an overridden open policy" do
    @user = OpenUser.new
    @user.assign(@attributes, [:name])
    assert_equal "Bob", @user.name
    assert_nil @user.role_id
  end

  test "a closed policy" do
    @user = ClosedUser.new
    @user.assign(@attributes)
    assert_nil @user.name
    assert_nil @user.role_id
  end

  test "an overridden closed policy" do
    @user = ClosedUser.new
    @user.assign(@attributes, [:name, :role_id])
    assert_equal "Bob", @user.name
    assert_equal 1, @user.role_id
  end

  test "a semi-closed policy" do
    @user = SemiClosedUser.new
    @user.assign(@attributes)
    assert_equal "Bob", @user.name
    assert_nil @user.role_id
  end

  test "an overridden semi-closed policy" do
    @user = SemiClosedUser.new
    @user.assign(@attributes, [:name, :role_id])
    assert_equal "Bob", @user.name
    assert_equal 1, @user.role_id
  end
end
