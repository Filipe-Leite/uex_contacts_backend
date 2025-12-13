class AddAddressFieldsToContacts < ActiveRecord::Migration[7.1]
  def change
    add_column :contacts, :cep, :string
    add_column :contacts, :street, :string
    add_column :contacts, :number, :string
    add_column :contacts, :complement, :string
    add_column :contacts, :neighborhood, :string
    add_column :contacts, :city, :string
    add_column :contacts, :state, :string
    add_column :contacts, :latitude, :decimal, precision: 10, scale: 6
    add_column :contacts, :longitude, :decimal, precision: 10, scale: 6
    
    add_index :contacts, :cpf, unique: true
    add_index :contacts, [:latitude, :longitude]
  end
end