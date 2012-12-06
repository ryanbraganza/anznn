When /^hospital "([^"]*)" has submitted the following baby codes$/ do |hospital, table|
  # table is a | 2012 | abcd      | main |pending
  hospital = Hospital.find_by_name!(hospital)
  roles = Role.where(name: [Role::DATA_PROVIDER, Role::DATA_PROVIDER_SUPERVISOR])
  user = hospital.users.where(role_id: roles).first!
  table.hashes.each do |hash|
    survey = hash[:form]
    Factory.create(:response, user: user, hospital: user.hospital,
                   submitted_status: Response::STATUS_SUBMITTED, baby_code: hash[:baby_code],
                   year_of_registration: hash[:year],survey: Survey.find_by_name!(survey))
  end
end
When /^I should see the following baby codes$/ do |table|
  # table is a | followup | 2011 | baby2     |pending
  # parse the html into an array of arrays
  form_divs = all('div.form')
  actual_baby_codes = form_divs.map do |form_div|
    form_header = form_div.find('h1.form')
    year_divs = form_div.all('div.year')

    year_contents = year_divs.map do |year_div|
      year_header = year_div.find('h2.year')
      baby_codes = year_div.all('li').map {|li| li.text }
      [year_header.text, baby_codes]
    end

    [form_header.text, year_contents]
  end

  expected_codes = {}

  hashes_by_form = table.hashes.group_by{|hash| hash[:form]}
  hashes_by_form.each do |form_name, hashes|
    hashes_by_year = hashes.group_by {|hash| hash[:year]}

    expected_codes[form_name] = {}
    hashes_by_year.each do |year, hashes|
      expected_codes[form_name][year] = hashes.map{|hash| hash[:baby_code]}.sort
    end
  end

  expected_codes = expected_codes.map do |form_name, expected_year_data|
    [form_name, expected_year_data.map{|year, expected_baby_codes| [year, expected_baby_codes] } ]
  end

  actual_baby_codes.should eq expected_codes
end