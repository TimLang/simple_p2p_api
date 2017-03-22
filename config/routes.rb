Rails.application.routes.draw do
  api_for '/apidoc'

  namespace :api do
    namespace :v1 do

      resources :accounts, only: [:create, :show] do
        collection do
          get :review_between_accounts
        end
      end

      resources :recharges, only: [] do
        collection do
          post :loan
          post :repayment
        end
      end

    end
  end

end
