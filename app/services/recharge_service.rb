
class RechargeService

  class << self

    #借款
    def loan debit_account_id, credit_account_id, amount
      debit_account = AccountService.account_review(debit_account_id)
      credit_account = AccountService.account_review(credit_account_id)
      amount = BigDecimal(amount)

      return false if debit_account.balance < amount

      ActiveRecord::Base.transaction do
        Recharge.create!(
          source_account_id: debit_account_id,
          dest_account_id: credit_account_id,
          recharge_type: Recharge::DEBIT,
          amount: -amount
        )
        Recharge.create!(
          source_account_id: credit_account_id,
          dest_account_id: debit_account_id,
          recharge_type:  Recharge::CREDIT,
          amount: amount
        )
        debit_account.update_attributes!(balance: debit_account.balance - amount)
        credit_account.update_attributes!(balance: credit_account.balance + amount)
      end
    end

    #还款
    def repayment credit_account_id, debit_account_id, amount
      credit_account = AccountService.account_review(credit_account_id)
      debit_account = AccountService.account_review(debit_account_id)
      amount = BigDecimal(amount)
      return false if (credit_account.balance < amount) || (amount > get_credit_amount_with_debit_account_id(credit_account_id, debit_account_id))

      ActiveRecord::Base.transaction do
        Recharge.create!(
          source_account_id: credit_account_id,
          dest_account_id: debit_account_id,
          recharge_type: Recharge::REPAYMENT,
          amount: -amount
        )
        Recharge.create!(
          source_account_id: debit_account_id,
          dest_account_id: credit_account_id,
          recharge_type: Recharge::RECOVER,
          amount: amount
        )
        credit_account.update_attributes!(balance: credit_account.balance - amount)
        debit_account.update_attributes!(balance: debit_account.balance + amount)
      end
    end

    #放贷总额
    def get_debit_amount account_id
      debit_amount = Recharge.where(source_account_id: account_id, recharge_type: Recharge::DEBIT).sum(:amount).abs
      recover_amount = Recharge.where(source_account_id: account_id, recharge_type: Recharge::RECOVER).sum(:amount).abs
      debit_amount - recover_amount
    end

    #借款总额
    def get_credit_amount account_id
      credit_amount = Recharge.where(source_account_id: account_id, recharge_type: Recharge::CREDIT).sum(:amount).abs
      repayment_amount = Recharge.where(source_account_id: account_id, recharge_type: Recharge::REPAYMENT).sum(:amount).abs
      credit_amount + (-repayment_amount)
    end

    def get_debit_amount_with_credit_account_id debit_account_id, credit_account_id
      debit_amount = Recharge.where(source_account_id: debit_account_id, dest_account_id: credit_account_id, recharge_type: Recharge::DEBIT).sum(:amount).abs
      recover_amount = Recharge.where(source_account_id: debit_account_id, dest_account_id: credit_account_id, recharge_type: Recharge::RECOVER).sum(:amount).abs
      debit_amount - recover_amount
    end

    def get_credit_amount_with_debit_account_id credit_account_id, debit_account_id
      credit_amount = Recharge.where(source_account_id: credit_account_id, dest_account_id: debit_account_id, recharge_type: Recharge::CREDIT).sum(:amount).abs
      repayment_amount = Recharge.where(source_account_id: credit_account_id, dest_account_id: debit_account_id, recharge_type: Recharge::REPAYMENT).sum(:amount).abs
      credit_amount + (-repayment_amount)
    end

  end

end
