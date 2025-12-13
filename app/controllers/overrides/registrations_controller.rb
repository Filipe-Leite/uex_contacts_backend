# frozen_string_literal: true

module Overrides
  class RegistrationsController < ::DeviseTokenAuth::RegistrationsController
    before_action :set_user_by_token, only: [:destroy, :update]
    before_action :validate_sign_up_params, only: :create
    before_action :validate_account_update_params, only: :update
    skip_after_action :update_auth_header, only: [:create, :destroy]

    def create
      puts "=" * 80
      puts "DEBUG: RegistrationsController#create chamado"
      puts "DEBUG: Parâmetros recebidos: #{params.inspect}"
      puts "DEBUG: sign_up_params: #{sign_up_params.inspect}"
      
      build_resource
      puts "DEBUG: @resource construído: #{@resource.inspect}"
      puts "DEBUG: @resource válido? #{@resource.valid?}"
      puts "DEBUG: @resource errors: #{@resource.errors.full_messages}" unless @resource.valid?

      unless @resource.present?
        puts "DEBUG ERRO: @resource não está presente!"
        raise DeviseTokenAuth::Errors::NoResourceDefinedError,
              "#{self.class.name} #build_resource does not define @resource,"\
              ' execution stopped.'
      end

      # give redirect value from params priority
      @redirect_url = params.fetch(
        :confirm_success_url,
        DeviseTokenAuth.default_confirm_success_url
      )
      puts "DEBUG: @redirect_url definido como: #{@redirect_url}"

      # success redirect url is required
      if confirmable_enabled? && !@redirect_url
        puts "DEBUG ERRO: confirmable_enabled? e @redirect_url faltando!"
        return render_create_error_missing_confirm_success_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      if blacklisted_redirect_url?(@redirect_url)
        puts "DEBUG ERRO: redirect_url não permitido: #{@redirect_url}"
        return render_create_error_redirect_url_not_allowed
      end

      # override email confirmation, must be sent manually from ctrl
      callback_name = defined?(ActiveRecord) && resource_class < ActiveRecord::Base ? :commit : :create
      puts "DEBUG: callback_name: #{callback_name}"
      
      resource_class.set_callback(callback_name, :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback(callback_name, :after, :send_on_create_confirmation_instructions)

      if @resource.respond_to? :skip_confirmation_notification!
        puts "DEBUG: skip_confirmation_notification! chamado"
        @resource.skip_confirmation_notification!
      end

      puts "DEBUG: Tentando salvar @resource..."
      if @resource.save
        puts "DEBUG SUCESSO: @resource salvo com ID: #{@resource.id}"
        yield @resource if block_given?

        unless @resource.confirmed?
          puts "DEBUG: Enviando instruções de confirmação..."
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: @redirect_url
          })
        end

        if active_for_authentication?
          puts "DEBUG: active_for_authentication? retornou true"
          @token = @resource.create_token
          puts "DEBUG: Token criado: #{@token.inspect}"
          @resource.save!
          update_auth_header
        else
          puts "DEBUG: active_for_authentication? retornou false"
        end

        render_create_success
      else
        puts "DEBUG ERRO: Falha ao salvar @resource"
        puts "DEBUG: Errors detalhados: #{@resource.errors.details}"
        puts "DEBUG: Errors full messages: #{@resource.errors.full_messages}"
        clean_up_passwords @resource
        render_create_error
      end
      puts "=" * 80
    end

    def update
      puts "=" * 80
      puts "DEBUG: RegistrationsController#update chamado"
      puts "DEBUG: @resource definido? #{@resource.present?}"
      puts "DEBUG: @resource: #{@resource.inspect}" if @resource.present?
      puts "DEBUG: Parâmetros recebidos: #{params.inspect}"
      puts "DEBUG: account_update_params: #{account_update_params.inspect}"
      
      if @resource
        puts "DEBUG: Método de update a ser usado: #{resource_update_method}"
        puts "DEBUG: Tentando atualizar usuário..."
        
        if @resource.send(resource_update_method, account_update_params)
          puts "DEBUG SUCESSO: Usuário atualizado"
          yield @resource if block_given?
          render_update_success
        else
          puts "DEBUG ERRO: Falha ao atualizar usuário"
          puts "DEBUG: Errors: #{@resource.errors.full_messages}"
          render_update_error
        end
      else
        puts "DEBUG ERRO: @resource não encontrado para update"
        render_update_error_user_not_found
      end
      puts "=" * 80
    end

    def destroy
      puts "=" * 80
      puts "DEBUG: RegistrationsController#destroy chamado"
      puts "DEBUG: @resource definido? #{@resource.present?}"
      puts "DEBUG: @resource ID: #{@resource.id if @resource.present?}"
      
      if @resource
        puts "DEBUG: Tentando destruir usuário..."
        @resource.destroy
        yield @resource if block_given?
        render_destroy_success
      else
        puts "DEBUG ERRO: @resource não encontrado para destroy"
        render_destroy_error
      end
      puts "=" * 80
    end

    def sign_up_params
      params.permit(*params_for_resource(:sign_up))
    end

    def account_update_params
      params.permit(*params_for_resource(:account_update))
    end

    protected

    def build_resource
      puts "DEBUG build_resource: Iniciando construção do resource"
      puts "DEBUG build_resource: sign_up_params: #{sign_up_params.inspect}"
      
      @resource = resource_class.new(sign_up_params)
      @resource.provider = provider
      puts "DEBUG build_resource: Provider definido como: #{provider}"

      # honor devise configuration for case_insensitive_keys
      if resource_class.case_insensitive_keys.include?(:email)
        puts "DEBUG build_resource: Email será downcase (case_insensitive_keys ativo)"
        @resource.email = sign_up_params[:email].try(:downcase)
      else
        puts "DEBUG build_resource: Email mantém case original"
        @resource.email = sign_up_params[:email]
      end
      
      puts "DEBUG build_resource: @resource construído: #{@resource.inspect}"
    end

    def render_create_error_missing_confirm_success_url
      puts "DEBUG: render_create_error_missing_confirm_success_url chamado"
      response = {
        status: 'error',
        data:   resource_data
      }
      message = I18n.t('devise_token_auth.registrations.missing_confirm_success_url')
      render_error(422, message, response)
    end

    def render_create_error_redirect_url_not_allowed
      puts "DEBUG: render_create_error_redirect_url_not_allowed chamado"
      response = {
        status: 'error',
        data:   resource_data
      }
      message = I18n.t('devise_token_auth.registrations.redirect_url_not_allowed', redirect_url: @redirect_url)
      render_error(422, message, response)
    end

    def render_create_success
      puts "DEBUG: render_create_success chamado"
      render json: {
        status: 'success',
        data:   resource_data
      }
    end

    def render_create_error
      puts "DEBUG: render_create_error chamado"
      render json: {
        status: 'error',
        data:   resource_data,
        errors: resource_errors
      }, status: 422
    end

    def render_update_success
      puts "DEBUG: render_update_success chamado"
      render json: {
        status: 'success',
        data:   resource_data
      }
    end

    def render_update_error
      puts "DEBUG: render_update_error chamado"
      render json: {
        status: 'error',
        errors: resource_errors
      }, status: 422
    end

    def render_update_error_user_not_found
      puts "DEBUG: render_update_error_user_not_found chamado"
      render_error(404, I18n.t('devise_token_auth.registrations.user_not_found'), status: 'error')
    end

    def render_destroy_success
      puts "DEBUG: render_destroy_success chamado"
      render json: {
        status: 'success',
        message: I18n.t('devise_token_auth.registrations.account_with_uid_destroyed', uid: @resource.uid)
      }
    end

    def render_destroy_error
      puts "DEBUG: render_destroy_error chamado"
      render_error(404, I18n.t('devise_token_auth.registrations.account_to_destroy_not_found'), status: 'error')
    end

    private

    def resource_update_method
      method = if DeviseTokenAuth.check_current_password_before_update == :attributes
        'update_with_password'
      elsif DeviseTokenAuth.check_current_password_before_update == :password && account_update_params.key?(:password)
        'update_with_password'
      elsif account_update_params.key?(:current_password)
        'update_with_password'
      else
        'update'
      end
      puts "DEBUG resource_update_method: retornando '#{method}'"
      method
    end

    def validate_sign_up_params
      puts "DEBUG validate_sign_up_params: validando #{sign_up_params.inspect}"
      validate_post_data sign_up_params, I18n.t('errors.messages.validate_sign_up_params')
    end

    def validate_account_update_params
      puts "DEBUG validate_account_update_params: validando #{account_update_params.inspect}"
      validate_post_data account_update_params, I18n.t('errors.messages.validate_account_update_params')
    end

    def validate_post_data which, message
      puts "DEBUG validate_post_data: which vazio? #{which.empty?}"
      render_error(:unprocessable_entity, message, status: 'error') if which.empty?
    end

    def active_for_authentication?
      result = !@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?
      puts "DEBUG active_for_authentication?: retornando #{result}"
      result
    end
  end
end