require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ResponsesHelper. For example:
#
# describe ResponsesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end

describe ResponsesHelper do
  describe "Generating response page titles" do
    it "should string together survey, baby code and year of reg" do
      response = Factory(:response, baby_code: "Bcdef", year_of_registration: 2015, survey: Factory(:survey, name: "My Survey"))
      helper.response_title(response).should eq("My Survey - Baby Code Bcdef - Year of Registration 2015")
    end
  end
end
