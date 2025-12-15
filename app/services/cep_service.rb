class CepService
  class CepError < StandardError; end
  class InvalidCepError < CepError; end
  class CepNotFoundError < CepError; end
  class ApiError < CepError; end
  
  BASE_URL = 'https://viacep.com.br/ws'.freeze
  
  def self.find(cep)
    new(cep).find
  end
  
  def initialize(cep)
    @cep = cep.to_s.gsub(/\D/, '')
  end
  
  def find
    validate_cep!
    
    response = HTTParty.get("#{BASE_URL}/#{@cep}/json/", {
      headers: { 'Content-Type' => 'application/json' },
      timeout: 10
    })
    
    handle_response(response)
  rescue HTTParty::Error, SocketError, Timeout::Error => e
    raise ApiError, "Erro na comunicação com o serviço de CEP: #{e.message}"
  end
  
  private
  
  def validate_cep!
    raise InvalidCepError, 'CEP deve ter 8 dígitos' unless @cep.match?(/^\d{8}$/)
  end
  
  def handle_response(response)
    data = JSON.parse(response.body)
    
    if data['erro']
      raise CepNotFoundError, 'CEP não encontrado'
    end
    
    {
      street: data['logradouro'].presence || '',
      neighborhood: data['bairro'].presence || '',
      city: data['localidade'].presence || '',
      state: data['uf'].presence || '',
      cep: data['cep'].presence || @cep
    }
  end
end