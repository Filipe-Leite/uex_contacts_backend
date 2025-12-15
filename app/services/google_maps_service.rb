class GoogleMapsService
  class GoogleMapsError < StandardError; end
  
  API_KEY = 'AIzaSyB3Xi_ZV3Fvya6fxSHIi0Hr7z_G5ick28I' 
  
  BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze
  
  def self.get_coordinates(address)
    
    unless API_KEY.present?
      return nil
    end
    
    begin
      
      response = HTTParty.get(BASE_URL, {
        query: {
          address: address,
          key: API_KEY
        },
        timeout: 10
      })
      
      
      data = JSON.parse(response.body)
      
      if data['status'] == 'OK' && data['results'].any?
        location = data['results'].first['geometry']['location']
        coordinates = {
          latitude: location['lat'].to_s,
          longitude: location['lng'].to_s
        }
        
        coordinates
      else
        nil
      end
      
    rescue HTTParty::Error => e
      raise GoogleMapsError, "HTTParty Error: #{e.message}"
    rescue JSON::ParserError => e
      raise GoogleMapsError, "JSON Parse Error: #{e.message}"
    rescue => e
      raise GoogleMapsError, "Erro inesperado: #{e.message}"
    end
  end
end