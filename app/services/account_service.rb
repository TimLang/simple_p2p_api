
class AccountService

  class << self

    # 账户详情，包括借款和放贷信息
    def account_review account_id
       account = Account.find account_id
       account_id = account.id

       account.credit_amount = RechargeService.get_credit_amount(account_id)
       account.debit_amount = RechargeService.get_debit_amount(account_id)
       account
    end

    #返回两账户间当前的借入借出总额
    def review_between_accounts first_account_id, second_account_id
      first_account = Account.find(first_account_id)
      second_account = Account.find(second_account_id)

      first_account_id = first_account.id
      second_account_id = second_account.id

      first_account_debit_amount = RechargeService.get_debit_amount_with_credit_account_id(first_account_id, second_account_id)
      first_account_crebit_amount = RechargeService.get_credit_amount_with_debit_account_id(first_account_id, second_account_id)

      second_account_debit_amount = RechargeService.get_debit_amount_with_credit_account_id(second_account_id, first_account_id)
      second_account_crebit_amount = RechargeService.get_credit_amount_with_debit_account_id(second_account_id, first_account_id)

      {
        first_account_debit_amount: first_account_debit_amount,
        first_account_crebit_amount: first_account_crebit_amount,
        second_account_debit_amount: second_account_debit_amount,
        second_account_crebit_amount: second_account_crebit_amount
      }
    end

  end

end
