class ServicesController < ApplicationController
    before_action :authenticate_user!
    
    def show
        begin
            cep_data = CepService.find(params[:cep])

            render json: cep_data, status: :ok
        rescue CepService::InvalidCepError => e
            render json: { error: e.message }, status: :unprocessable_entity
        rescue CepService::CepNotFoundError => e
            render json: { error: e.message }, status: :not_found
        rescue CepService::CepError => e
            render json: { error: e.message }, status: :service_unavailable
        rescue => e
            Rails.logger.error "CEP lookup error: #{e.message}"
            render json: { error: 'Erro interno do servidor' }, status: :internal_server_error
        end
    end
end