require 'spec_helper'

describe QuestionProblemOrganiser do
  describe "Takes errors an warnings from all responses and organises them by question and error message" do
    it "should accept a set of problems and organise them for display" do
      qpo = QuestionProblemOrganiser.new
      qpo.add_problems("q1", "b1", %w(fwa fwb), %w(wa wb))
      qpo.add_problems("q2", "b1", %w(fwc), %w(wc wd))
      qpo.add_problems("q3", "b1", %w(fwe fwf), [])
      qpo.add_problems("q1", "b2", %w(fwa), %w(wa))
      qpo.add_problems("q2", "b2", %w(fwc fwd), %w(wd))
      qpo.add_problems("q3", "b2", [], %w(we))

      organised = qpo.organised_by_question_and_message
      organised.should be_a(Array)
      organised.size.should == 23
      organised[0].should eq(['Column', 'Type', 'Message', 'Number of records'])
      organised[1].should eq(['q1', 'Error', 'fwa', '2'])
      organised[2].should eq(['', '', 'b1, b2', ''])
      organised[3].should eq(['q1', 'Error', 'fwb', '1'])
      organised[4].should eq(['', '', 'b1', ''])
      organised[5].should eq(['q1', 'Warning', 'wa', '2'])
      organised[6].should eq(['', '', 'b1, b2', ''])
      organised[7].should eq(['q1', 'Warning', 'wb', '1'])
      organised[8].should eq(['', '', 'b1', ''])

      organised[9].should eq(['q2', 'Error', 'fwc', '2'])
      organised[10].should eq(['', '', 'b1, b2', ''])
      organised[11].should eq(['q2', 'Error', 'fwd', '1'])
      organised[12].should eq(['', '', 'b2', ''])
      organised[13].should eq(['q2', 'Warning', 'wc', '1'])
      organised[14].should eq(['', '', 'b1', ''])
      organised[15].should eq(['q2', 'Warning', 'wd', '2'])
      organised[16].should eq(['', '', 'b1, b2', ''])

      organised[17].should eq(['q3', 'Error', 'fwe', '1'])
      organised[18].should eq(['', '', 'b1', ''])
      organised[19].should eq(['q3', 'Error', 'fwf', '1'])
      organised[20].should eq(['', '', 'b1', ''])
      organised[21].should eq(['q3', 'Warning', 'we', '1'])
      organised[22].should eq(['', '', 'b2', ''])
    end
  end
end