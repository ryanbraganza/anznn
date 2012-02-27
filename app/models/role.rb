class Role < ActiveRecord::Base

  SUPER_USER = 'Administrator'
  DATA_PROVIDER = 'Data Provider'
  DATA_PROVIDER_SUPERVISOR = 'Data Provider Supervisor'

  has_many :users

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :by_name, order('name')
  scope :superuser_roles, where(name: SUPER_USER)

  def super_user?
    self.name.eql? SUPER_USER
  end

  def self.super_user_role
    SUPER_USER
  end

end
