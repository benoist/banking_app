require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup 
  	@user = User.create(email: 'example@mail.com', password: '123456789', 
  		password_confirmation: '123456789')
    @user2 = users(:one)
    @user2.account = accounts(:one)
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "email should be present" do
  	@user.email = "     "
  	assert_not @user.valid?
  end

  test "email validation should acccept valid addresses" do
  	valid_addresses = %w[user@example.com USER@foo.com A_US@foo.bar.org first.last@goo.jpp alice+bob@baz.cn]
  	valid_addresses.each do |valid_address|
  		@user.email = valid_address
  		assert @user.valid?, "#{valid_address.inspect} should be valid"
  	end
  end

  test "email validation should reject invalid addresses" do
  	invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
  		foo@bar_baz$.c$m foo@bar+bar.com]
  		invalid_addresses.each do |invalid_add|
  			@user.email = invalid_add
  			assert_not @user.valid?, "#{invalid_add.inspect} should be invalid"
  		end
  end 

  test "email addresses should be unique" do
 		duplicate_user = @user.dup
 		duplicate_user.email = @user.email.upcase
 		@user.save
 		assert_not duplicate_user.valid?
 end

  	test "password should be present (nonblank)" do
 		@user.password = @user.password_confirmation = " " * 8
 		assert_not @user.valid?
 	end

 	test "password should have a minimum length" do
 		@user.password = @user.password_confirmation = "a" * 3
 		assert_not @user.valid?
 	end

 	  test "associated account should be destroyed" do
    assert_equal @user.account.balance, 0
    assert_difference ['User.count'], -1 do
      @user.destroy
    end
  end

  test "deposit account" do
  	@old_balance = @user.balance 	
    #checking balance
  	assert_equal @old_balance, 0
  	@user.deposit(5)
  	assert_not_equal @user.account.balance, @old_balance
  	@old_balance = @user.account.balance 	
  	@user.deposit(-55)
  	assert_equal @user.account.balance, @old_balance
  end

  test "withdraw account" do
  	@old_balance = @user.balance 	
  	assert_equal @old_balance, 0
  	@user.withdraw(5)
  	assert_equal @user.account.balance, @old_balance
  	@user.deposit(500)
  	@user.withdraw(300)
  	assert_equal @user.account.balance, 200
  	@old_balance = @user.account.balance 	
  	@user.withdraw(-100)
  	assert_equal @user.account.balance, @old_balance
  end

  test "transfer account" do
    @user.deposit(500) 
    assert @user2.balance, 0
    assert_equal @user.balance, 500
    @user.transfer(@user2.id, 300)
    assert_equal @user.balance, 200
    assert_equal 300, @user2.reload.balance
    @user.transfer(@user2.id, 500)
    assert_equal 300, @user2.reload.balance
    assert_equal @user.balance, 200
  end


end
