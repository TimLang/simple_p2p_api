
class Recharges < ActiveRecord::Migration
  def change
    create_table :recharges do |t|
      t.integer  :source_account_id
      t.integer  :dest_account_id
      t.string   :recharge_type
      t.decimal  :amount
    end
  end
end
