def create_roles_and_permissions
  Role.delete_all

  Role.create!(:name => Role::SuperUserRole)
  Role.create!(:name => Role::DATA_PROVIDER)
  Role.create!(:name => Role::DATA_PROVIDER_SUPERVISOR)

end
