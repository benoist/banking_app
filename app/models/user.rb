class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :account
  has_many :logs

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
			format: { with: VALID_EMAIL_REGEX }

  after_commit :set_account
  attr_accessor :flash_notice

 

  def set_account
	if self.account.nil? 
		self.create_account(id: self.id, balance: 0.0)
  	end
  end

  # It is breaking the DRY but I am using this methods just to highlight the difference between them
  # We could use a single method operation and hash the operation (deposit, withdraw and transfer)
  # In this example, the idea was creating a log historic but I run out of time.


  	def deposit(amount, note="command line")
  		#making sure user send a numeric number
  		if (amount.is_a? Numeric)
  			#testing deposit is not negative and update
			if amount > 0  
				new_balance = self.account.balance + amount
				self.account.update(balance: new_balance, note: "‎€#{amount} credited by #{note}")
				register_log("‎€#{amount} credited by #{note}", self.id, "deposit", self.account.balance)
			else
				self.flash_notice = "Can't make the deposit because amount is inferior to zero"
			end
		else
			self.flash_notice = "We only accept numbers"
		end
	end

	def withdraw(amount, note="command line")
		if (amount.is_a? Numeric)
			if (amount > 0 && (self.account.balance - amount) > 0) 
				new_balance = self.account.balance - amount
				self.account.update(balance: new_balance, note: "‎€#{amount} withdraw by #{note}")
				register_log("‎€#{amount} withdraw by #{note}", self.id, "withdraw", self.account.balance)
			elsif amount < 0
				self.flash_notice = "Can't withdraw. Amount inferior to zero"
			elsif (self.account.balance - amount) > 0
				self.flash_notice = "Can't withdraw. You don't have enough credit to make this operation"
			else
				self.flash_notice = "Can't withdraw. Please check the values"
			end
		else
			self.flash_notice = "We only accept numbers"
		end
	end

	def transfer(user_id, amount, note="command line")
		if (amount.is_a? Numeric)
			if (amount > 0 && (self.account.balance - amount) > 0)
				begin
					acc = User.find(user_id)
				rescue ActiveRecord::RecordNotFound => e
					puts e
				end
				if acc.nil?
					self.flash_notice = "User do not exist"
				else
					if acc.account.nil?
						acc.set_account
					end
					new_balance = acc.account.balance + amount
					acc.account.update(balance: new_balance, note: "‎€#{amount} transfer by #{note}")
					register_log("‎€#{amount} transfer by #{note}", acc.id, "transfer", acc.account.balance)
					if acc.save
						new_balance = self.account.balance - amount
						self.account.update(balance: new_balance, note: "‎€#{amount} transfer by #{note}")
						register_log("‎€#{amount} transfer by #{note}", self.id, "transfer", self.account.balance)
					else
						self.flash_notice = "Transfer was declined"
					end
				end
			elsif amount < 0
				self.flash_notice = "Amount inferior to zero"
			elsif (self.account.balance - amount) > 0
				self.flash_notice = "You don't have enough credit to make this operation"
			else
				self.flash_notice = "Please check the values"
			end
		else
			self.flash_notice = "We only accept numbers"
		end			
	end

	private 
		def register_log(desc, user_id, op, balance)
			@log = Log.new(description: desc, user_id: user_id, data_created: DateTime.now, operation: op, balance: balance)
			@log.save
		end
end
