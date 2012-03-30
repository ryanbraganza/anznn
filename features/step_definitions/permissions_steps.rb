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

Then /^I should get a security error when I visit (.*)$/ do |page|
  visit path_to(page)
  pending
  page.should have_content("You tried to access a page you are not authorised to view.")
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

