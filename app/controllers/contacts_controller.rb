class ContactsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        @contacts = Contact.all

        p "@contacts > #{@contacts.inspect}"
        
        render json: @contacts, status: :ok
    end
    
    
    private

    
    def contact_params
        params.require(:contact).permit(
            :name, :cpf, :phone, :cep, :street, :number, :complement,
            :neighborhood, :city, :state, :latitude, :longitude
        )
    end

end