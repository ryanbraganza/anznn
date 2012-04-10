Then /^the file I received should match "([^"]*)"$/ do |filename|
  exemplar_file = Rails.root.join("features/sample_data/downloads", filename)
  expected = CSV.read(exemplar_file)
  actual = CSV.parse(page.source)
  actual.should eq(expected)
end
