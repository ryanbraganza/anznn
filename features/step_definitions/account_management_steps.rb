Given /^I have access requests$/ do |table|
  table.hashes.each do |hash|
    Factory(:user, hash.merge(:status => 'U'))
  end
end

Given /^I have users$/ do |table|
  table.hashes.each do |hash|
    hospital_name = hash.delete('hospital')
    role_name = hash.delete('role')
    role = role_name.blank? ? nil : Role.find_by_name!(role_name)
    hospital = hospital_name.blank? ? nil : Hospital.find_by_name!(hospital_name)
    Factory(:user, hash.merge(status: 'A', hospital: hospital, role: role))
  end
end

Given /^I have roles$/ do |table|
  table.hashes.each do |hash|
    Factory(:role, hash)
  end
end

And /^I have role "([^"]*)"$/ do |name|
  Factory(:role, :name => name)
end


Given /^I have permissions$/ do |table|
  table.hashes.each do |hash|
    create_permission_from_hash(hash)
  end
end

def create_permission_from_hash(hash)
  roles = hash[:roles].split(",")
  create_permission(hash[:entity], hash[:action], roles)
#  create_permission(hash[:entity], hash[:action], hash[:roles])
end

def create_permission(entity, action, roles)
  permission = Permission.new(:entity => entity, :action => action)
  permission.save!
  roles.each do |role_name|
    role = Role.where(:name => role_name).first
    role.permissions << permission
    role.save!
  end
end

Given /^"([^"]*)" has role "([^"]*)"$/ do |email, role_name|
  user = User.find_by_email!(email)
  role = Role.find_by_name!(role_name)
  user.role = role
  user.hospital = nil if role_name == "Administrator"
  user.save!(:validate => false)
end

When /^I follow "Approve" for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  click_link("approve_#{user.id}")
end

When /^I follow "Reject" for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  click_link("reject_#{user.id}")
end

When /^I follow "Reject as Spam" for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  click_link("reject_as_spam_#{user.id}")
end

When /^I follow "View Details" for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  click_link("view_#{user.id}")
end

When /^I follow "Edit Access Level" for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  click_link("edit_role_#{user.id}")
end

Given /^"([^"]*)" is deactivated$/ do |email|
  user = User.find_by_email!(email)
  user.deactivate
end

Given /^"([^"]*)" is pending approval$/ do |email|
  user = User.find_by_email!(email)
  user.status = "U"
  user.save!
end

Given /^"([^"]*)" is rejected as spam$/ do |email|
  user = User.find_by_email!(email)
  user.reject_access_request
end

Then /^the filter by hospital select should contain$/ do |table|
  field = find_field("Filter by hospital")
  groups = field.all("optgroup")

  actual_options = []
  groups.each do |group|
    options = group.all("option").collect(&:text)
    actual_options << [group[:label], options]
  end

  expected_options = table.raw.collect { |row| [row[0], row[1].split(",").collect { |i| i.strip }] }
  actual_options.should eq(expected_options)
end
