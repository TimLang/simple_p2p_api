
module Api
  module V1

    class RechargesController < Api::V1::ApplicationController
      before_action :validate_accounts

      define_action :loan, {
        name: '借款接口',
        description: '调用：curl -k -X POST -d"debit_account_id=1&credit_account_id=3&amount=6000" https://103.29.68.133/api/v1/recharges/loan',
        params: {
          type: 'object',
          required: ['debit_account_id', 'credit_account_id', 'amount'],
          properties: {
            debit_account_id: {
              description: '放贷账户id'
            },
            credit_account_id: {
              description: '借贷账户id'
            },
            amount: {
              description: '借贷金额'
            }
          }
        },
          return: {
            type: 'object',
            properties: {
              error_code: {
                type: 'integer',
                description: '0表示成功，1表示失败'
              },
              data: {
                properties: {
                  messages: {
                    type: 'string',
                    description: '如果失败，此处为失败信息'
                  }
                }
              }
            }
        }
      } do
        requires! :credit_account_id, type: Integer
        requires! :debit_account_id, type: Integer
        params_validate!(:amount, ParameterValueNotCorrect.new("金额（amount）必须为大于0且最多小数点两位的数字")) {|entry| entry =~ /\A[0-9]+([.]{1}[0-9]+)?\z/ && (entry.to_i > 0)}

        result = RechargeService.loan(params[:debit_account_id], params[:credit_account_id], params[:amount])
        render json: {error_code: (result ? 0 : 1), data: {messages: (result ? "借款成功" : "借款失败")}}.to_json
      end

      define_action :repayment, {
        name: '还款接口',
        description: '调用：curl -k -X POST -d"debit_account_id=1&credit_account_id=2&amount=1001" https://103.29.68.133/api/v1/recharges/repayment',
        params: {
          type: 'object',
          required: ['debit_account_id', 'credit_account_id', 'amount'],
          properties: {
            debit_account_id: {
              description: '放贷账户id'
            },
            credit_account_id: {
              description: '借贷账户id'
            },
            amount: {
              description: '还贷金额'
            }
            }
          },
          return: {
            type: 'object',
            properties: {
              error_code: {
                type: 'integer',
                description: '0表示成功，1表示失败'
              },
              data: {
                properties: {
                  messages: {
                    type: 'string',
                    description: '如果失败，此处为失败信息'
                  }
                }
              }
            }
          }
      } do

        requires! :credit_account_id, type: Integer
        requires! :debit_account_id, type: Integer

        params_validate!(:amount, ParameterValueNotCorrect.new("金额（amount）必须为大于0且最多小数点两位的数字")) {|entry| entry =~ /\A[0-9]+([.]{1}[0-9]+)?\z/ && (entry.to_i > 0)}

        result = RechargeService.repayment(params[:credit_account_id], params[:debit_account_id], params[:amount])
        render json: {error_code: (result ? 0 : 1), data: {messages: (result ? "还款成功" : "还款失败")}}.to_json
      end


      private

      def validate_accounts
        if Account.find_by_id(params[:debit_account_id]).nil? || Account.find_by_id(params[:credit_account_id]).nil?
          raise ActiveRecord::RecordNotFound.new("没有找到相应的账户信息")
        else
          true
        end
      end

    end

  end
end
