class ContactsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        @contacts = Contact.all.order(name: :asc)
        
        render json: @contacts, status: :ok
    end

    def create
      @contact = current_user.contacts.new(contact_params)

      if @contact.cpf.present?
        return render json: { error: 'Invalid CPF' }, status: :unprocessable_entity unless valid_cpf?(@contact.cpf)
        return render json: { error: 'CPF already registered' }, status: :unprocessable_entity if current_user.contacts.exists?(cpf: @contact.cpf)
      end

      required_fields = [:name, :phone, :cep, :street, :number, :neighborhood, :city, :state]
      missing_fields = required_fields.select { |field| @contact.send(field).blank? }
      
      unless missing_fields.empty?
        return render json: { error: "Required fields: #{missing_fields.join(', ')}" }, status: :unprocessable_entity
      end
      
      begin
        coordinates = get_coordinates_from_address
        if coordinates
          @contact.latitude = coordinates[:latitude]
          @contact.longitude = coordinates[:longitude]
        end
      rescue => e
        puts "Coordinates error: #{e.message}"
      end

      if @contact.save
        render json: @contact, status: :created
      else
        render json: { errors: @contact.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private

    def contact_params
        params.require(:contact).permit(
          :name, 
          :cpf, 
          :phone, 
          :cep, 
          :street, 
          :number, 
          :complement, 
          :neighborhood, 
          :city, 
          :state
        )
      end

    def valid_cpf?(cpf)
        cpf_numbers = cpf.to_s.gsub(/[^0-9]/, '')
        
        return false unless cpf_numbers.length == 11
        return false if cpf_numbers.chars.uniq.length == 1
        
        sum = 0

        9.times do |i|
          sum += cpf_numbers[i].to_i * (10 - i)
        end

        first_digit = (sum * 10) % 11
        first_digit = 0 if first_digit == 10
        
        return false unless first_digit == cpf_numbers[9].to_i

        sum = 0

        10.times do |i|
          sum += cpf_numbers[i].to_i * (11 - i)
        end

        second_digit = (sum * 10) % 11
        second_digit = 0 if second_digit == 10
        
        second_digit == cpf_numbers[10].to_i
    end

    def get_coordinates_from_address
      
      address = [
        contact_params[:street],
        contact_params[:number],
        contact_params[:neighborhood],
        contact_params[:city],
        contact_params[:state],
        'Brasil'
      ].compact.join(', ')
      
    
        coordinates = GoogleMapsService.get_coordinates(address)

        coordinates
      rescue => e
        Rails.logger.error "Error in get_coordinates_from_address: #{e.message}"
        nil
      end

  end