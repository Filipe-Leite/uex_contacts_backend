require 'cpf_cnpj'

class Contact < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true
  validates :cpf, presence: true, uniqueness: { scope: :user_id }
  validates :phone, presence: true
  validates :street, presence: true
  validates :number, presence: true
  validates :neighborhood, presence: true
  validates :city, presence: true
  validates :state, presence: true, length: { is: 2 }
  
  validate :valid_cpf
  
  def full_address
    "#{street}, #{number} #{complement.present? ? "- #{complement}" : ""}, #{neighborhood}, #{city} - #{state}, #{zip_code}"
  end
  
  private
  
  def valid_cpf
    return if cpf.blank?
    
    unless CPF.valid?(cpf)
      errors.add(:cpf, 'invalid')
    end
  end
  
  def address_changed?
    street_changed? || number_changed? || city_changed? || state_changed? || zip_code_changed?
  end
  
end