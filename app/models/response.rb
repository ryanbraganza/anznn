class Response < ActiveRecord::Base
  belongs_to :survey
  belongs_to :user
  has_many :answers

  validates_presence_of :baby_code
end
