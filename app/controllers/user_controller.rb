class UserController < ApplicationController

	before_action :authenticate_user!, except: :home
	before_filter :valid_amount?, only: :make_deposit
	after_filter :flash_notice, except: [:home, :index]

	def index
		@log = Log.where(user_id: current_user.id).order("data_created desc")
	end

	def transfer
		@users = User.all.where.not('id = ?', current_user.id)
	end

	def  make_deposit
		current_user.deposit(params[:amount].to_f, params[:note])
		if flash[:notice].nil?
			flash[:notice] = "Success"
		end
		redirect_to index_path
	end

	def make_withdraw
		current_user.withdraw(params[:amount].to_f, params[:note])
		flash[:notice] = "Success"
		redirect_to index_path
	end

	def make_transfer
				current_user.transfer(params[:user_id].to_i, params[:amount].to_f, params[:note])
				flash[:notice] = "Success"
				redirect_to index_path
	end

	private
	 def flash_notice
       if !current_user.flash_notice.nil?
          flash[:notice] = current_user.flash_notice
       end
   	 end 

   	 def valid_amount?
		if params[:amount].to_f < 0 
			flash[:notice] = "Number can't be 0 or inferior "
			redirect_to(:back)
		elsif params[:note] == ""
			flash[:notice] = "User Responsible can't be blank"
			redirect_to(:back)
		end
   	 end


end
