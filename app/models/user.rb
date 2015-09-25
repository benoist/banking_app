class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :account
  before_create :built_default_account
  has_many :logs

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
			format: { with: VALID_EMAIL_REGEX }
  
  attr_accessor :flash_notice

  	#return the balance
  	def balance
  		account.balance
  	end

  	def deposit(amount, note="command line")
  		#making sure user send a numeric number
  		if valid_number?(amount)
				self.account.balance += amount
				register_log("‎€#{amount} credited by #{note}", self.id,  __method__, self.balance) if self.account.save
		else
			self.flash_notice = "Amount invalid"
		end		
	end

	def withdraw(amount, note="command line")
		if valid_number?(amount)
			#slipt condition in order to avoid error in case of non numeric value
			if (self.balance - amount) > 0
				self.account.balance -= amount
				register_log("‎€#{amount} withdraw by #{note}", self.id, __method__, self.balance) if self.account.save
			else
				self.flash_notice = "Can't withdraw. You don't have enough credit to make this operation"
			end
		else
			self.flash_notice = "Can't withdraw. Please check the values"
		end
	end

	def transfer(user_id, amount, note="command line")
		if valid_number?(amount) 
			#slipt condition in order to avoid error in case of non numeric value
			if (self.balance - amount) > 0
				begin
					credited_user = User.find(user_id)
					#rescue error in case of no user with the id informed
				rescue ActiveRecord::RecordNotFound => e
					return "User Not Found. Please check the user id"
					false
				end
				#return if the user informed was the same to tranfer
				return false if credited_user.id == self.id
				credited_user.account.balance += amount
				register_log("‎€#{amount} transfer by #{note}", credited_user.id, __method__, credited_user.balance) if credited_user.account.save
				
				if credited_user.account.save
					self.account.balance -= amount
					register_log("‎€#{amount} transfer by #{note}", self.id, __method__, self.balance) if self.account.save
				else
					self.flash_notice = "Transfer was declined"
				end
			else
				self.flash_notice = "You don't have enough credit to make this operation"
			end 
		else
			self.flash_notice = "Please check the values"
		end
	end

	private 
		def register_log(desc, user_id, op, balance)
			@log = Log.new(description: desc, user_id: user_id, data_created: DateTime.now, operation: op, balance: balance)
			@log.save!
		end

		def valid_number?(number)
			#make sure it gets a numeric
			if (number.is_a? Numeric)
				#make sure the account will always receive a positive number
				number > 0 ? true : false
			else
				self.flash_notice = "We only accept numbers"
				false
			end 
		end

		def built_default_account
			build_account(balance: 0)
			true
		end


end
