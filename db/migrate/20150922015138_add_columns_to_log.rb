class AddColumnsToLog < ActiveRecord::Migration
  def change
  	 add_column :logs, :balance, :float
     add_column :logs, :operation, :string
  end
end
