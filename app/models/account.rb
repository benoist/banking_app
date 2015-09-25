class Account < ActiveRecord::Base
	belongs_to :user, dependent: :destroy
    validates :balance, presence: true, :numericality => { :greater_than_or_equal_to => 0 }



end
