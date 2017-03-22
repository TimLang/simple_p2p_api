
class Accounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.decimal  :balance
      t.timestamps null: true
    end
  end
end
