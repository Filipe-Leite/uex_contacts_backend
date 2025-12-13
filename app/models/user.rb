class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :contacts, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
end
