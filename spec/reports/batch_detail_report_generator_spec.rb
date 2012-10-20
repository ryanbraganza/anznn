require 'spec_helper'

describe BatchDetailReportGenerator do

  it "should write the provided rows to the csv" do
    problems = []
    problems << ['B1', 'C1', 'Err', '2', 'Hello']
    problems << ['B1', 'C2', 'Warn', 'asdf', 'Msg']
    organiser = mock
    organiser.should_receive(:detailed_problems).and_return(problems)
    
    BatchDetailReportGenerator.generate_report(organiser, Rails.root.join("tmp/details.csv"))

    rows = CSV.read("tmp/details.csv")
    rows.size.should eq(3)
    rows[0].should eq(["BabyCODE", "Column Name", "Type", "Value", "Message"])
    rows[1].should eq(['B1', 'C1', 'Err', '2', 'Hello'])
    rows[2].should eq(['B1', 'C2', 'Warn', 'asdf', 'Msg'])
  end
end
