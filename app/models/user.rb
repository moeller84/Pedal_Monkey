class User < ApplicationRecord
has_many :trip_members, dependent: :destroy #Rob said (probably wrong)#
has_many :trips, through: :trip_members
has_attachment :photo
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
