Then /^I should get the following security outcomes$/ do |table|
  table.hashes.each do |hash|
    page_to_visit = hash[:page]
    outcome = hash[:outcome]
    message = hash[:message]
    visit path_to(page_to_visit)
    if outcome == "error"
      page.should have_content(message)
      current_path = URI.parse(current_url).path
      current_path.should == path_to("the home page")
    else
      current_path = URI.parse(current_url).path
      current_path.should == path_to(page_to_visit)
    end

  end
end

Then /^I should get a security error when I visit (.*)$/ do |page_name|
  visit path_to(page_name)
  page.should have_content("You tried to access a page you are not authorised to view.")
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

Then /^I should get a security error when I try to (post|put) to (.*)$/ do |method, name|
  case name
    when "the configure year of registration range page"
      Capybara.current_session.driver.submit(method, update_year_of_registration_configuration_items_path, {})
      page.should have_content("You tried to access a page you are not authorised to view.")
    else
      raise "Unknown post path #{name} - add it to the step in permissions_steps.rb"
  end
end
