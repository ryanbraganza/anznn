def create_roles_and_permissions
  Role.delete_all

  #TODO: create your roles here
  superuser = "Administrator"
  Role.create!(:name => superuser)
  Role.create!(:name => "Data Provider")

end
