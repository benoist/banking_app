class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :description
      t.datetime :data_created
      t.references :user
      t.timestamps null: false
    end
  end
end
