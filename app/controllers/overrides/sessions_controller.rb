module Overrides
  class SessionsController < DeviseTokenAuth::SessionsController
    before_action :set_user_by_token, only: [:destroy]
    after_action :reset_session, only: [:destroy]

    def new
      render_new_error
    end

    def create

      if field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first
        q_value = get_case_insensitive_field_from_resource_params(field)

        @resource = find_resource(field, q_value)
      end

      if @resource && valid_params?(field, q_value) &&
         (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)

        valid_password = @resource.valid_password?(resource_params[:password])

        if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) ||
           !valid_password
          return render_create_error_bad_credentials
        end

        create_and_assign_token

        sign_in(@resource, scope: :user, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success

      elsif @resource
        if @resource.respond_to?(:locked_at) && @resource.locked_at
          render_create_error_account_locked
        else
          render_create_error_not_confirmed
        end
      else
        hash_password_in_paranoid_mode
        render_create_error_bad_credentials
      end
    end

    def destroy

      user = remove_instance_variable(:@resource) if @resource
      client = @token.client if @token
      token = @token.token if @token
      expiry = @token.expiry if @token

      @token.clear! if @token

      if user && client && user.tokens[client]

        user.tokens.delete(client)
        user.save!

        if DeviseTokenAuth.cookie_enabled
          cookies.delete(
            DeviseTokenAuth.cookie_name,
            domain: DeviseTokenAuth.cookie_attributes[:domain]
          )
        end

        yield user if block_given?
        render_destroy_success
      else
        render_destroy_error
      end
    end

    protected

    def valid_params?(key, val)
      resource_params[:password] && key && val
    end

    private

    def resource_params
      permitted = params.permit(*params_for_resource(:sign_in))
      permitted
    end
  end
end
