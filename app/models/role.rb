class Role < ActiveRecord::Base

  SuperUserRole = 'Administrator'

  has_many :users

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :by_name, order('name')
  scope :superuser_roles, where(name: SuperUserRole)

  def is_data_provider?
    self.name == 'Data Provider'
  end

  def super_user?
    self.name.eql? SuperUserRole
  end

  def self.super_user_role
    SuperUserRole
  end

end
