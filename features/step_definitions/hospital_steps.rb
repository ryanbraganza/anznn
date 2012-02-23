Given /^I have hospitals$/ do |table|
  table.hashes.each do |hash|
    Factory(:hospital, hash)
  end
end
