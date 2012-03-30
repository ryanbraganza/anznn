Then /^I should see "([^"]*)" table with$/ do |table_id, expected_table|
  actual = find("table##{table_id}").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
  chatty_diff_table!(expected_table, actual)
end

Then /the "(.*)" table should have (\d+) columns/ do |table_id, num_columns|
  ths = find("table##{table_id}").all('th')
  ths.count.should eq num_columns.to_i
end

Then /^I should see field "([^"]*)" with value "([^"]*)"$/ do |field, value|
  # this assumes you're using the helper to render the field which sets the div id based on the field name
  div_id = field.tr(" ,", "_").downcase
  # use a quoted selector so it doesn't pass through the selectors.rb logic
  div_scope = "\"div#display_#{div_id}\""
  with_scope(div_scope) do
    page.should have_content(field)
    page.should have_content(value)
  end
end

Then /^I should see fields displayed$/ do |table|
  # as above, this assumes you're using the helper to render the field which sets the div id based on the field name
  table.hashes.each do |row|
    field = row[:field]
    value = row[:value]
    div_id = field.tr(" ,", "_").downcase
    div_scope = "div#display_#{div_id}"
    with_scope(div_scope) do
      page.should have_content(field)
      page.should have_content(value)
    end
  end
end

Then /^I should see button "([^"]*)"$/ do |arg1|
  page.should have_xpath("//input[@value='#{arg1}']")
end

Then /^I should see image "([^"]*)"$/ do |arg1|
  page.should have_xpath("//img[contains(@src, #{arg1})]")
end

Then /^I should not see button "([^"]*)"$/ do |arg1|
  page.should have_no_xpath("//input[@value='#{arg1}']")
end

Then /^I should see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_xpath("//input[@value='#{button}']")
  end
end

Then /^I should not see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_no_xpath("//input[@value='#{button}']")
  end
end

Then /^I should get a security error "([^"]*)"$/ do |message|
  page.should have_content(message)
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

Then /^I should see link "([^"]*)"$/ do |text|
  page.should have_link(text)
end

Then /^I should not see link "([^"]*)"$/ do |text|
  page.should_not have_link(text)
end

Then /^I should see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should have_link(text)
  end
end

Then /^I should not see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should_not have_link(text)
  end
end

When /^(?:|I )deselect "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    unselect(value, :from => field)
  end
end

When /^I select$/ do |table|
  table.hashes.each do |hash|
    When "I select \"#{hash[:value]}\" from \"#{hash[:field]}\""
  end
end

When /^I fill in$/ do |table|
  table.hashes.each do |hash|
    When "I fill in \"#{hash[:field]}\" with \"#{hash[:value]}\""
  end
end

# can be helpful for @javascript features in lieu of "show me the page
Then /^pause$/ do
  puts "Press Enter to continue"
  STDIN.getc
end

Then /^the "([^"]*)" select should contain$/ do |label, table|
  field = find_field(label)
  options = field.all("option")
  actual_options = options.collect(&:text)
  expected_options = table.raw.collect { |row| row[0] }
  actual_options.should eq(expected_options)
end

def chatty_diff_table!(expected_table, actual, opts={})
  begin
    expected_table.diff!(actual, opts)
  rescue Cucumber::Ast::Table::Different
    puts "Tables were as follows:"
    puts expected_table
    raise
  end
end
When /^I should see the access denied error$/ do
  step "I should see \"You tried to access a page you are not authorised to view.\""
end

When /^I should see that the "([^"]*)" update succeeded for (.*)$/ do |update, obj|
  step "I should see \"The #{update} for #{obj} was successfully updated.\""
end

Then /^I should receive a file with name "([^"]*)" and type "([^"]*)"$/ do |name, type|
  page.response_headers['Content-Type'].should == type
  page.response_headers['Content-Disposition'].should include("filename=\"#{name}\"")
  page.response_headers['Content-Disposition'].should include("attachment")
end
