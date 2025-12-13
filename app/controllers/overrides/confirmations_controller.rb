module Overrides
  class ConfirmationsController < DeviseTokenAuth::ConfirmationsController

    def show
      puts "\n>>> [Confirmação] Iniciando ConfirmationsController#show"
      puts ">>> [Confirmação] Parâmetros recebidos: #{params.inspect}"
      puts ">>> [Confirmação] Token de confirmação: #{resource_params[:confirmation_token]}"
      puts ">>> [Confirmação] Redirect URL: #{redirect_url}"

      @resource = resource_class.confirm_by_token(resource_params[:confirmation_token])
      
      puts ">>> [Confirmação] Após confirm_by_token"
      puts ">>> [Confirmação] Resource: #{@resource.inspect}"
      puts ">>> [Confirmação] Erros: #{@resource.errors.full_messages}" if @resource.errors.any?

      if @resource.errors.empty?
        puts "\n>>> [Confirmação] Usuário confirmado com sucesso!"
        puts ">>> [Confirmação] Email: #{@resource.email}"
        puts ">>> [Confirmação] ID: #{@resource.id}"
        puts ">>> [Confirmação] confirmed_at: #{@resource.confirmed_at}"
        puts ">>> [Confirmação] Antes da confirmação: #{@resource.confirmed_at_before_last_save}"
        puts ">>> [Confirmação] Depois da confirmação: #{@resource.confirmed_at}"

        yield @resource if block_given?

        redirect_header_options = { account_confirmation_success: true }

        if signed_in?(resource_name)
          puts ">>> [Confirmação] Usuário já está logado, gerando novos tokens"
          token = signed_in_resource.create_token
          signed_in_resource.save!

          redirect_headers = build_redirect_headers(token.token,
                                                  token.client,
                                                  redirect_header_options)

          redirect_to_link = signed_in_resource.build_auth_url(redirect_url, redirect_headers)
          puts ">>> [Confirmação] URL de redirecionamento (logado): #{redirect_to_link}"
        else
          redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
          puts ">>> [Confirmação] URL de redirecionamento (não logado): #{redirect_to_link}"
        end

        puts ">>> [Confirmação] Redirecionando para: https://www.jinner.co.uk"
        redirect_to(jinner_url, allow_other_host: true)
      else
        puts "\n>>> [Confirmação] ERRO ao confirmar usuário!"
        puts ">>> [Confirmação] Erros detalhados:"
        @resource.errors.full_messages.each { |msg| puts ">>> [Confirmação] - #{msg}" }

        if redirect_url
          puts ">>> [Confirmação] Redirecionando para página de erro"
          redirect_to DeviseTokenAuth::Url.generate(jinner_url, account_confirmation_success: true), allow_other_host: true
        else
          puts ">>> [Confirmação] Nenhum redirect_url definido, retornando 404"
          raise ActionController::RoutingError, 'Not Found'
        end
      end
    end

    private

    def jinner_url
      "https://www.jinner.co.uk"
    end
  end
end