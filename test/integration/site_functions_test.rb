require 'test_helper'

class SiteFunctionsTest < ActionDispatch::IntegrationTest

  # test "the truth" do
  #   assert true
  # end

 

  def setup 
  	@user = User.create(email: 'example@mail.com', password: '123456789', 
  		password_confirmation: '123456789')
    @user2 = users(:one)
    @user2.save!
  end

  test "deposit for not logged users " do
  	delete destroy_user_session_path(@user.id)
  	get deposit_path
  	assert_redirected_to new_user_session_path
  end

   test "deposit for logged users " do   	
	  post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  	get deposit_path
  	assert_response :success
  	assert_select 'input[name=note]'
  	@user.deposit(50, 'Life')
  end


  test "withdraw for not logged users " do
  	delete destroy_user_session_path(@user.id)
  	get withdraw_path
  	assert_redirected_to new_user_session_path
  end

   test "withdraw for logged users " do   	
	post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  	get withdraw_path
  	assert_response :success
  	assert_select 'input[name=note]'
  	assert_select 'input[name=amount]'
  	@user.create_account
  	@user.withdraw(9, 'Life')
  	assert_not_equal @user.account.balance, 41
  	@user.deposit(50, 'Life')
  	@user.withdraw(9, 'Life')
  	assert_equal @user.account.balance, 41
  end



  test "transfer for not logged users " do
  	delete destroy_user_session_path(@user.id)
  	get transfer_path
  	assert_redirected_to new_user_session_path
  end

   test "transfer for logged users " do   	
	post_via_redirect user_session_path, 'user[email]' => @user.email, 'user[password]' => @user.password
  	get transfer_path
  	assert_response :success
  	assert_select 'input[name=note]'
    @user2.create_account
  	@user2.deposit(9, 'life')
    assert @user2.balance, 9
    assert @user.balance, 0
  	@user2.transfer(@user.id, 3)
  	assert_not_equal @user2.balance, 9
  	#assert_equal @user.balance, 11
  end

end
