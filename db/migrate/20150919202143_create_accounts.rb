class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.float :balance, :default => 0
      t.string :note
      t.references :user
      t.timestamps null: false
    end
  end
end
