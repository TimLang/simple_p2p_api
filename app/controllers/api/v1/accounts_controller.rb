
module Api
  module V1

    class AccountsController < Api::V1::ApplicationController

      before_action :is_account_id_equal?, only: [:review_between_accounts]

      define_action :create, {
        name: '创建账户',
        description: '调用：curl -k -X POST -d "balance=5000" https://103.29.68.133/api/v1/accounts',
        params: {
          type: 'object',
          required: ['balance'],
          properties: {
            balance: {
              description: '余额'
            }
          }
        },
        return: {
          type: 'integer',
          properties: {
            id: {
              description: 'account id'
            }
          }
        }
      } do
        requires! :balance, type: Integer

        params_validate!(:balance, ParameterValueNotCorrect.new("余额（balance）必须为大于0且最多小数点两位的数字")) {|entry| entry =~ /\A[0-9]+([.]{1}[0-9]{1,2})?\z/ && (entry.to_i > 0)}

        result = if account=Account.create(balance: params[:balance])
                   account.id
                 else
                   0
                 end
        render json: result
      end

      define_action :show, {
        name: '账户明细',
        description: '调用：curl -k https://103.29.68.133/accounts/1',
        params: {
          type: 'object',
          required: ['id'],
          properties: {
            id: {
              description: '账户id'
            }
          }
        },
        return: {
          type: 'object',
          properties: {
            id: {
              description: 'PK'
            },
            balance: {
              description: '余额'
            },
            debit_amount: {
              description: '放贷金额'
            },
            credit_amount: {
              description: '借贷金额'
            }
          }
        }

      } do
        requires! :id, type: Integer

        raise ActiveRecord::RecordNotFound.new("没有找到相应的账户信息") if Account.find_by_id(params[:id]).nil?

        account = AccountService.account_review(params[:id])
        render json: { id: account.id, balance: account.balance, debit_amount: account.debit_amount, credit_amount: account.credit_amount }.to_json
      end

      define_action :review_between_accounts, {
        name: '任意两个用户之间当前的债务情况',
        description: '调用：curl -k https://103.29.68.133/api/v1/accounts/review_between_accounts?first_account_id=1&second_account_id=2',
        params: {
          type: 'object',
          required: ['first_account_id', 'second_account_id'],
          properties: {
            first_account_id: {
              description: '账户1id'
            },
            second_account_id: {
              description: '账户2id'
            }
          }
        },
        return: {
          type: 'object',
          properties: {
            first_account_debit_amount: {
              description: '账户1放贷金额'
            },
            first_account_crebit_amount: {
              description: '账户1借贷金额'
            },
            second_account_debit_amount: {
              description: '账户2放贷金额'
            },
            second_account_crebit_amount: {
              description: '账户2借贷金额'
            }
          }
        }

      } do

        requires! :first_account_id, type: Integer
        requires! :second_account_id, type: Integer

        raise ActiveRecord::RecordNotFound.new("没有找到相应的账户信息") if Account.find_by_id(params[:first_account_id]).nil? && Account.find_by_id(params[:second_account_id]).nil?

        render json: AccountService.review_between_accounts(params[:first_account_id], params[:second_account_id]).to_json
      end


      private

      def is_account_id_equal?
        if params[:first_account_id] == params[:second_account_id]
          raise ParameterValueNotCorrect.new("两个账户id不能相同")
        else
          true
        end
      end

    end
  end
end
