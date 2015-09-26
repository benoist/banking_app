require 'test_helper'

class UserControllerTest < ActionController::TestCase
	include Devise::TestHelpers 

  # test "the truth" do
  #   assert true
  # end

  def setup 
  	@user = User.create(email: 'example@mail.com', password: '123456789', 
  		password_confirmation: '123456789')
  	@request.env["devise.mapping"] = Devise.mappings[:user]
  	@user1 = users(:one)
  	@user1.account = accounts(:one)
  end

  test "home page" do
  	get :home
  	assert_response :success  	
  end

  test "index page without authenticate" do
  	get :index
  	assert_redirected_to new_user_session_path
  end

  test "index page after authenticate" do
  	sign_in @user
  	get :index
  	assert_response :success
  end

  test "transfer page after authenticate" do
  	sign_in @user
  	get :transfer
  	assert_response :success
  	assert assigns(:users)
  	assert_select 'form'
  	assert_select 'select', /.+/
  end

  test "make deposit without authenticate" do
  	get :deposit
  	assert_redirected_to new_user_session_path
  end


  test "make deposit after authenticate" do
  	@request.env['HTTP_REFERER'] = 'http://test.com/deposit'
  	sign_in @user
	get :deposit
  	assert_response :success
  	assert_select 'form input'
  	patch :make_deposit
  	request.env["HTTP_REFERER"] =
  	assert_equal flash[:notice], "Amount invalid"
  	assert_equal @user.reload.balance, 0
  end

  test "make deposit negative number" do
	@request.env['HTTP_REFERER'] = 'http://test.com/deposit'
  	sign_in @user
	get :deposit
  	assert_response :success
  	assert_select 'form input'
  	patch :make_deposit, amount: -50
  	assert_equal flash[:notice], "Number can't be 0 or inferior"
  	assert_equal @user.reload.balance, 0
  end
  
   test "make deposit responsible empty" do
	@request.env['HTTP_REFERER'] = 'http://test.com/deposit'
  	sign_in @user
	get :deposit
  	assert_response :success
  	assert_select 'form input'
  	patch :make_deposit, amount: 50, note: ""
  	assert_equal flash[:notice], "User Responsible can't be blank"
  	assert_equal @user.reload.balance, 0
  end

test "make deposit successfully" do
	@request.env['HTTP_REFERER'] = 'http://test.com/deposit'
  	sign_in @user
	get :deposit
  	assert_response :success
  	assert_select 'form input'
  	patch :make_deposit, amount: 50, note: "credited by me"
  	assert_equal flash[:notice], "Success"
  	assert_equal @user.reload.balance, 50
  end

    test "make withdraw without authenticate" do
  	get :withdraw
  	assert_redirected_to new_user_session_path
  end


  test "make withdraw after authenticate" do
  	@request.env['HTTP_REFERER'] = 'http://test.com/withdraw'
  	sign_in @user
	get :withdraw
  	assert_response :success
  	assert_select 'form input'
  	patch :make_withdraw
  	assert_equal flash[:notice], "Can't withdraw. Please check the values"
  	assert_equal @user.reload.balance, 0
  end

  test "make withdraw negative number" do
	@request.env['HTTP_REFERER'] = 'http://test.com/withdraw'
  	sign_in @user
	get :withdraw
  	assert_response :success
  	assert_select 'form input'
  	patch :make_withdraw, amount: -50
  	assert_equal flash[:notice], "Number can't be 0 or inferior"
  	assert_equal @user.reload.balance, 0
  end
  
   test "make withdraw responsible empty" do
	@request.env['HTTP_REFERER'] = 'http://test.com/withdraw'
  	sign_in @user
	get :withdraw
  	assert_response :success
  	assert_select 'form input'
  	patch :make_withdraw, amount: 50, note: ""
  	assert_equal flash[:notice], "User Responsible can't be blank"
  	assert_equal @user.reload.balance, 0
  end

test "make withdraw successfully" do
	@request.env['HTTP_REFERER'] = 'http://test.com/withdraw'
  	sign_in @user
  	@user.deposit(100)
	get :withdraw
  	assert_response :success
  	assert_select 'form input'
  	patch :make_withdraw, amount: 50, note: "debited by me"
  	assert_equal flash[:notice], "Success"
  	assert_equal @user.reload.balance, 50
  end


   test "make transfer without authenticate" do
  	get :transfer
  	assert_redirected_to new_user_session_path
  end


  test "make transfer after authenticate" do
  	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
	get :withdraw
  	assert_response :success
  	assert_select 'form input'
  	patch :make_withdraw
  	assert_equal flash[:notice], "Can't withdraw. Please check the values"
  	assert_equal @user.reload.balance, 0
  end

  test "make transfer negative number" do
	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
	get :transfer
  	assert_response :success
  	assert_select 'form input'
  	patch :make_transfer, amount: -50
  	assert_equal flash[:notice], "Number can't be 0 or inferior"
  	assert_equal @user.reload.balance, 0
  end
 
  test "make transfer responsible empty" do
	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
	get :transfer
  	assert_response :success
  	assert_select 'form input'
  	patch :make_transfer, amount: 50, note: ""
  	assert_equal flash[:notice], "User Responsible can't be blank"
  	assert_equal @user.reload.balance, 0
  end

test "make transfer without user" do
	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
  	@user.deposit(100)
	get :transfer
  	assert_response :success
  	assert_select 'form input'
  	patch :make_transfer, amount: 50, note: "transfered by me"
  	assert_equal flash[:notice], "Please inform the user"
  	assert_equal @user.reload.balance, 100
  end 

  test "make transfer with wrong user id" do
	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
  	@user.deposit(100)
	get :transfer
  	assert_response :success
  	assert_select 'form input'
  	patch :make_transfer, amount: 50, note: "transfered by me", user_id: 999
	# do not tranfer
  	assert_equal @user.reload.balance, 100
  end 


test "make transfer with right user id" do
	@request.env['HTTP_REFERER'] = 'http://test.com/transfer'
  	sign_in @user
  	@user.deposit(100)
	get :transfer
  	assert_response :success
  	assert_select 'form input'
  	patch :make_transfer, amount: 50, note: "transfered by me", user_id: @user1.id
	assert_equal flash[:notice], "Success"
  	assert_equal @user.reload.balance, 50
  	assert_equal @user1.reload.balance, 50
  end 

end
