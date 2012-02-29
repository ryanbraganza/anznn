require 'spec_helper'

describe BatchSummaryReportGenerator do

  it "should create a pdf in the specified path" do
    batch_file = Factory(:batch_file)
    organiser = mock
    organiser.should_receive(:aggregated_by_question_and_message).and_return([["row1", "row1"], ["row2", "row2"]])
    BatchSummaryReportGenerator.generate_report(batch_file, organiser, "tmp/summary.pdf")
    File.exist?("tmp/summary.pdf").should be_true
  end
end