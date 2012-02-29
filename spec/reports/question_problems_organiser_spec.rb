require 'spec_helper'

describe QuestionProblemsOrganiser do

  let(:qpo) do
    qpo = QuestionProblemsOrganiser.new
    qpo.add_problems("q1", "b1", %w(fwa fwb), %w(wa wb), "q1-b1-a")
    qpo.add_problems("q2", "b1", %w(fwc), %w(wc wd), "q2-b1-a")
    qpo.add_problems("q3", "b1", %w(fwe fwf), [], "q3-b1-a")
    qpo.add_problems("q1", "b2", %w(fwa), %w(wa), "q1-b2-a")
    qpo.add_problems("q2", "b2", %w(fwc fwd), %w(wd), "q2-b2-a")
    qpo.add_problems("q3", "b2", [], %w(we), "q3-b2-a")
    qpo
  end

  it "for aggregated report, takes errors and warnings and aggregates them by question and error message" do
    aggregated = qpo.aggregated_by_question_and_message
    aggregated.should be_a(Array)
    aggregated.size.should == 23
    aggregated[0].should eq(['Column', 'Type', 'Message', 'Number of records'])
    aggregated[1].should eq(['q1', 'Error', 'fwa', '2'])
    aggregated[2].should eq(['', '', 'b1, b2', ''])
    aggregated[3].should eq(['q1', 'Error', 'fwb', '1'])
    aggregated[4].should eq(['', '', 'b1', ''])
    aggregated[5].should eq(['q1', 'Warning', 'wa', '2'])
    aggregated[6].should eq(['', '', 'b1, b2', ''])
    aggregated[7].should eq(['q1', 'Warning', 'wb', '1'])
    aggregated[8].should eq(['', '', 'b1', ''])

    aggregated[9].should eq(['q2', 'Error', 'fwc', '2'])
    aggregated[10].should eq(['', '', 'b1, b2', ''])
    aggregated[11].should eq(['q2', 'Error', 'fwd', '1'])
    aggregated[12].should eq(['', '', 'b2', ''])
    aggregated[13].should eq(['q2', 'Warning', 'wc', '1'])
    aggregated[14].should eq(['', '', 'b1', ''])
    aggregated[15].should eq(['q2', 'Warning', 'wd', '2'])
    aggregated[16].should eq(['', '', 'b1, b2', ''])

    aggregated[17].should eq(['q3', 'Error', 'fwe', '1'])
    aggregated[18].should eq(['', '', 'b1', ''])
    aggregated[19].should eq(['q3', 'Error', 'fwf', '1'])
    aggregated[20].should eq(['', '', 'b1', ''])
    aggregated[21].should eq(['q3', 'Warning', 'we', '1'])
    aggregated[22].should eq(['', '', 'b2', ''])
  end

  it "For detailed report it takes errors and warnings orders them by baby code, question and error message" do
    details = qpo.detailed_problems
    details.should be_a(Array)
    details.size.should == 15
    details[0].should eq(['b1', 'q1', 'Error', 'q1-b1-a', 'fwa'])
    details[1].should eq(['b1', 'q1', 'Error', 'q1-b1-a', 'fwb'])
    details[2].should eq(['b1', 'q1', 'Warning', 'q1-b1-a', 'wa'])
    details[3].should eq(['b1', 'q1', 'Warning', 'q1-b1-a', 'wb'])

    details[4].should eq(['b1', 'q2', 'Error', 'q2-b1-a', 'fwc'])
    details[5].should eq(['b1', 'q2', 'Warning', 'q2-b1-a', 'wc'])
    details[6].should eq(['b1', 'q2', 'Warning', 'q2-b1-a', 'wd'])

    details[7].should eq(['b1', 'q3', 'Error', 'q3-b1-a', 'fwe'])
    details[8].should eq(['b1', 'q3', 'Error', 'q3-b1-a', 'fwf'])

    details[9].should eq(['b2', 'q1', 'Error', 'q1-b2-a', 'fwa'])
    details[10].should eq(['b2', 'q1', 'Warning', 'q1-b2-a', 'wa'])

    details[11].should eq(['b2', 'q2', 'Error', 'q2-b2-a', 'fwc'])
    details[12].should eq(['b2', 'q2', 'Error', 'q2-b2-a', 'fwd'])
    details[13].should eq(['b2', 'q2', 'Warning', 'q2-b2-a', 'wd'])

    details[14].should eq(['b2', 'q3', 'Warning', 'q3-b2-a', 'we'])
  end

end