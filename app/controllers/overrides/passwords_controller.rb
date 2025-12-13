# frozen_string_literal: true

module Overrides
  class PasswordsController < DeviseTokenAuth::PasswordsController
    # before_action :validate_redirect_url_param, only: [:create, :edit]
    # skip_after_action :update_auth_header, only: [:create, :edit]
    skip_before_action :validate_redirect_url_param, only: [:create, :edit, :update]

    def create
      clean_params = params.permit(:email, :redirect_url, password: [:email, :redirect_url])
      
      return render_create_error_missing_email unless clean_params[:email] || clean_params.dig(:password, :email)

      @email = clean_params[:email] || clean_params.dig(:password, :email)
      @redirect_url = clean_params[:redirect_url] || clean_params.dig(:password, :redirect_url)

      @resource = find_resource(:uid, @email.downcase)

      if @resource
        yield @resource if block_given?
        
        CustomDeviseMailer.reset_password_instructions(
          @resource,
          @resource.send(:set_reset_password_token),
          redirect_url: @redirect_url
        ).deliver_now

        render_create_success
      else
        render_not_found_error
      end
    end

    def edit
      find_resource_with_token

      return render_edit_error unless valid_resource_for_password_reset?

      handle_password_reset_redirect
    end

  def update
    Rails.logger.info "PasswordReset: Iniciando processo de atualização"
    Rails.logger.info "PasswordReset: Parâmetros recebidos - Token: #{params[:reset_password_token]}, Password: [FILTERED], Confirmation: [FILTERED]"
    
    update_params = params.permit(:password, :password_confirmation, :reset_password_token)
    
    Rails.logger.info "PasswordReset: Token recebido cru: #{update_params[:reset_password_token]}"
    
    @resource = resource_class.with_reset_password_token(update_params[:reset_password_token])
    
    if @resource
      Rails.logger.info "PasswordReset: Usuário encontrado - Email: #{@resource.email}, Token DB: #{@resource.reset_password_token}, Token Enviado: #{update_params[:reset_password_token]}"
      Rails.logger.info "PasswordReset: Token foi enviado em: #{@resource.reset_password_sent_at}, Validade: #{@resource.reset_password_sent_at + Devise.reset_password_within}"
    else
      Rails.logger.error "PasswordReset: NENHUM usuário encontrado com o token fornecido"
      Rails.logger.error "PasswordReset: Token hash gerado: #{Devise.token_generator.digest(resource_class, :reset_password_token, update_params[:reset_password_token])}"
    end

    unless @resource
      return render json: { 
        success: false,
        errors: ['Token de redefinição inválido ou expirado']
      }, status: :unauthorized
    end

    if @resource.reset_password_period_valid?
      Rails.logger.info "PasswordReset: Token dentro do período válido"
    else
      Rails.logger.error "PasswordReset: Token EXPIRADO - Data atual: #{Time.now}, Data limite: #{@resource.reset_password_sent_at + Devise.reset_password_within}"
    end

    if update_params[:password] != update_params[:password_confirmation]
      Rails.logger.error "PasswordReset: Senhas não coincidem - Password: #{update_params[:password]}, Confirmation: #{update_params[:password_confirmation]}"
      return render json: {
        success: false,
        errors: ['As senhas não coincidem']
      }, status: :unprocessable_entity
    end

    Rails.logger.info "PasswordReset: Tentando atualizar senha para o usuário: #{@resource.email}"
    
    if @resource.reset_password(update_params[:password], update_params[:password_confirmation])
      Rails.logger.info "PasswordReset: Senha atualizada com SUCESSO para: #{@resource.email}"
      render json: {
        success: true,
        data: {
          email: @resource.email
        },
        message: 'Senha redefinida com sucesso'
      }
    else
      Rails.logger.error "PasswordReset: FALHA ao atualizar senha - Erros: #{@resource.errors.full_messages.join(', ')}"
      render json: {
        success: false,
        errors: @resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

    private

    def find_and_send_reset_instructions
      @email = get_case_insensitive_field_from_resource_params(:email)
      @resource = find_resource(:uid, @email)

      if @resource
        yield @resource if block_given?
        send_reset_instructions
      else
        render_not_found_error
      end
    end

    def send_reset_instructions
      @resource.send_reset_password_instructions(
        email: @email,
        provider: 'email',
        redirect_url: @redirect_url,
        client_config: params[:config_name]
      )

      if @resource.errors.empty?
        render_create_success
      else
        render_create_error @resource.errors
      end
    end

    def find_resource_with_token
      @resource = resource_class.with_reset_password_token(resource_params[:reset_password_token])
    end

    def valid_resource_for_password_reset?
      @resource&.reset_password_period_valid?
    end

    def handle_password_reset_redirect
      token = @resource.create_token unless require_client_password_reset_token?
      prepare_resource_for_password_change

      if require_client_password_reset_token?
        redirect_to frontend_password_reset_url(params[:reset_password_token]), allow_other_host: true
      else
        handle_normal_password_reset_flow(token)
      end
    end

    def prepare_resource_for_password_change
      @resource.skip_confirmation! if confirmable_enabled? && !@resource.confirmed_at
      @resource.allow_password_change = true if recoverable_enabled?
      @resource.save!
      yield @resource if block_given?
    end

    def handle_normal_password_reset_flow(token)
      set_token_in_cookie(@resource, token) if DeviseTokenAuth.cookie_enabled
      
      redirect_header_options = { reset_password: true }
      redirect_headers = build_redirect_headers(token.token, token.client, redirect_header_options)
      redirect_to(@resource.build_auth_url(@redirect_url, redirect_headers), redirect_options)
    end

    def frontend_password_reset_url(token)
      if Rails.env.production?
        "https://jinner.co.uk/auth/new_password?reset_password_token=#{token}"
      else
        "http://localhost:8000/auth/new_password?reset_password_token=#{token}"
      end
    end

    def set_resource_for_update
      if require_client_password_reset_token? && resource_params[:reset_password_token]
        @resource = resource_class.with_reset_password_token(resource_params[:reset_password_token])
        @token = @resource.create_token if @resource
      else
        @resource = set_user_by_token
      end
    end

    def update_password_and_respond
      return render_update_error_unauthorized unless @resource
      return render_update_error_password_not_required unless @resource.provider == 'email'
      return render_update_error_missing_password unless password_params_present?

      if update_resource_password
        handle_successful_password_update
      else
        render_update_error
      end
    end

    def password_params_present?
      password_resource_params[:password] && password_resource_params[:password_confirmation]
    end

    def update_resource_password
      @resource.send(resource_update_method, password_resource_params)
    end

    def handle_successful_password_update
      @resource.allow_password_change = false if recoverable_enabled?
      @resource.save!
      yield @resource if block_given?
      render_update_success
    end

    def resource_update_method
      allow_password_change = recoverable_enabled? && @resource.allow_password_change == true || require_client_password_reset_token?
      DeviseTokenAuth.check_current_password_before_update == false || allow_password_change ? 'update' : 'update_with_password'
    end

    def resource_params
      params.permit(:email, :reset_password_token, :redirect_url, :config_name)
    end

    def password_resource_params
      params.permit(*params_for_resource(:account_update))
    end

    def render_create_error_missing_email
      render_error(401, I18n.t('devise_token_auth.passwords.missing_email'))
    end

    def render_create_error_missing_redirect_url
      render_error(401, I18n.t('devise_token_auth.passwords.missing_redirect_url'))
    end

    def render_error_not_allowed_redirect_url
      render_error(422, I18n.t('devise_token_auth.passwords.not_allowed_redirect_url', redirect_url: @redirect_url))
    end

    def render_create_success
      render json: success_response
    end

    def success_response
      {
        success: true,
        message: success_message('passwords', @email)
      }
    end

    def render_create_error(errors)
      render json: { success: false, errors: errors }, status: 400
    end

    def render_edit_error
      raise ActionController::RoutingError, 'Not Found'
    end

    def render_update_error_unauthorized
      render_error(401, 'Unauthorized')
    end

    def render_update_error_password_not_required
      render_error(422, I18n.t('devise_token_auth.passwords.password_not_required', provider: @resource.provider.humanize))
    end

    def render_update_error_missing_password
      render_error(422, I18n.t('devise_token_auth.passwords.missing_passwords'))
    end

    def render_update_success
      render json: {
        success: true,
        data: resource_data,
        message: I18n.t('devise_token_auth.passwords.successfully_updated')
      }
    end

    def render_update_error
      render json: { success: false, errors: resource_errors }, status: 422
    end

    def render_not_found_error
      Devise.paranoid ? render_create_success : render_user_not_found_error
    end

    def render_user_not_found_error
      render_error(404, I18n.t('devise_token_auth.passwords.user_not_found', email: @email))
    end

    def render_error(status, message, response = { status: 'error', data: resource_data })
      render json: response.merge(errors: [message]), status: status
    end

    def validate_redirect_url_param

      @redirect_url = params.fetch(:redirect_url, DeviseTokenAuth.default_password_reset_url)

      return render_create_error_missing_redirect_url unless @redirect_url
      return render_error_not_allowed_redirect_url if blacklisted_redirect_url?(@redirect_url)
    end

    def require_client_password_reset_token?
      DeviseTokenAuth.require_client_password_reset_token
    end
  end
end