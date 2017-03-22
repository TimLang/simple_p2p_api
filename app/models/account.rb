
class Account < ActiveRecord::Base
  attr_accessor :debit_amount, :credit_amount

  def inspect
    {
      id: self.id,
      balance: self.balance.to_f,
      debit_amount: self.debit_amount.to_f,
      credit_amount: self.credit_amount.to_f
    }
  end

end
