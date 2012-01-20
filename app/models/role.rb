class Role < ActiveRecord::Base

  has_many :users

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :by_name, order('name')
  scope :superuser_roles, where(name: 'Administrator')

  def is_data_provider?
    self.name == 'Data Provider'
  end

end
