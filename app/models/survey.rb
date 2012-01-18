class Survey < ActiveRecord::Base
  has_many :responses
  has_many :sections
end
