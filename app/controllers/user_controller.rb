class UserController < ApplicationController
	before_action :check_acc
	before_action :authenticate_user!, except: :home


	def index
		@log = Log.where(user_id: current_user.id).order("data_created desc")
	end

	def transfer
		@users = User.all.where.not('id = ?', current_user.id)
	end

	#As in the model, I am using different functions to highlight use of methods as required. 
	#It can be make by a single method which will perform the action of operation.
	def make_deposit
		if params[:amount].to_f < 0 
			flash[:danger] = "Number can't be 0 or inferior "
			redirect_to deposit_path
		elsif params[:note] == ""
			flash[:danger] = "User Responsible can't be blank"
			redirect_to deposit_path
		else
			current_user.deposit(params[:amount].to_f, params[:note])
			flash[:notice] = "Sucess"
			redirect_to index_path
		end
	end

	def make_withdraw
		if params[:amount].to_f < 0 && params[:note] == ""
			flash[:danger] = "Number can't be 0 or inferior and information can't be blank"
			redirect_to withdraw_path
		else
			current_user.withdraw(params[:amount].to_f, params[:note])
			flash[:notice] = "Sucess"
			redirect_to index_path
		end
	end

	def make_transfer
		
		if params[:amount].to_f < 0 && params[:note] == ""
			flash[:danger] = "Number can't be 0 or inferior and information can't be blank"
			redirect_to tranfer_path
		else
			current_user.transfer(params[:user_id].to_i, params[:amount].to_f, params[:note])
			flash[:notice] = "Sucess"
			redirect_to index_path
		end
	end

	private
		def check_acc
			if !current_user.nil?
				current_user.set_account
			end
		end

end
