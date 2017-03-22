
module Api
  module V1

    class ApplicationController < Lina::ApplicationController

      protect_from_forgery with: :null_session
      before_action :set_cache_control_headers
      skip_before_action :verify_authenticity_token

      class ParameterValueNotAllowed < ActionController::ParameterMissing
        attr_reader :values
        def initialize(param, values) # :nodoc:
          @param = param
          @values = values
          super("param: #{param} value not allowed: #{values}")
        end
      end

      class AccessDenied < StandardError; end
      class PageNotFound < StandardError; end

      class ParameterValueNotCorrect < StandardError
        def initialize(msg="")
          super(msg)
        end
      end

      rescue_from(ParameterValueNotCorrect) do |err|
        render json: { error: 'ParameterInvalid', message: err.message }, status: 400
      end

      rescue_from(ActionController::ParameterMissing) do |err|
        render json: { error: 'ParameterInvalid', message: err.message }, status: 400
      end

      rescue_from(ActiveRecord::RecordInvalid) do |err|
        render json: { error: 'RecordInvalid', message: err.message }, status: 400
      end

      rescue_from(AccessDenied) do |err|
        render json: { error: 'Forbidden', message: "没有访问权限" }, status: 403
      end

      rescue_from(ActiveRecord::RecordNotFound) do |err|
        render json: { error: 'ResourceNotFound', message: err.message }, status: 404
      end

      def requires!(name, opts = {})
        opts[:require] = true
        optional!(name, opts)
      end

      def optional!(name, opts = {})
        if params[name].blank? && opts[:require] == true
          raise ActionController::ParameterMissing.new(name)
        end

        if opts[:values] && params[name].present?
          values = opts[:values].to_a
          if !values.include?(params[name]) && !values.include?(params[name].to_i)
            raise ParameterValueNotAllowed.new(name, opts[:values])
          end
        end

        if params[name].blank? && opts[:default].present?
          params[name] = opts[:default]
        end
      end

      def params_validate!(name, custom_error=nil)
        params_entry = params[name]
        unless (yield(params_entry))
          if custom_error
            raise custom_error
          else
            raise ParameterValueNotAllowed.new(name, params_entry)
          end
        end
      end


    private

    def set_cache_control_headers
      request.session_options[:skip] = true
      response.headers['Cache-Control'] = 'public, no-cache'
    end

    end

  end

end
