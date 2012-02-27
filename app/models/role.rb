class Role < ActiveRecord::Base

  SuperUserRole = 'Administrator'
  DATA_PROVIDER = 'Data Provider'
  DATA_PROVIDER_SUPERVISOR = 'Data Provider Supervisor'

  has_many :users

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :by_name, order('name')
  scope :superuser_roles, where(name: SuperUserRole)

  def super_user?
    self.name.eql? SuperUserRole
  end

  def self.super_user_role
    SuperUserRole
  end

end
