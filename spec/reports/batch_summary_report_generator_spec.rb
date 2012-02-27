require 'spec_helper'

describe BatchSummaryReportGenerator do

  it "should return the file path of the generated pdf" do
    batch_file = Factory(:batch_file)
    generator = BatchSummaryReportGenerator.new(batch_file)
    file_path = generator.generate_report
    file_path.should eq("tmp/#{batch_file.id}-summary.pdf")
    File.exist?(file_path).should be_true
  end
end