require 'spec_helper'

describe QuestionProblemDetailOrganiser do
  describe "Takes errors and warnings from all answers and orders them by baby code, question and error message" do
    it "should accept a set of problems and organise them for display" do
      qpo = QuestionProblemDetailOrganiser.new
      qpo.add_problems("q1", "b1", %w(fwa fwb), %w(wa wb), "q1-b1-a")
      qpo.add_problems("q2", "b1", %w(fwc), %w(wc wd), "q2-b1-a")
      qpo.add_problems("q3", "b1", %w(fwe fwf), [], "q3-b1-a")
      qpo.add_problems("q1", "b2", %w(fwa), %w(wa), "q1-b2-a")
      qpo.add_problems("q2", "b2", %w(fwc fwd), %w(wd), "q2-b2-a")
      qpo.add_problems("q3", "b2", [], %w(we), "q3-b2-a")

      organised = qpo.sorted_problems
      organised.should be_a(Array)
      organised.size.should == 15
      organised[0].should eq(['b1', 'q1', 'Error', 'q1-b1-a', 'fwa'])
      organised[1].should eq(['b1', 'q1', 'Error', 'q1-b1-a', 'fwb'])
      organised[2].should eq(['b1', 'q1', 'Warning', 'q1-b1-a', 'wa'])
      organised[3].should eq(['b1', 'q1', 'Warning', 'q1-b1-a', 'wb'])

      organised[4].should eq(['b1', 'q2', 'Error', 'q2-b1-a', 'fwc'])
      organised[5].should eq(['b1', 'q2', 'Warning', 'q2-b1-a', 'wc'])
      organised[6].should eq(['b1', 'q2', 'Warning', 'q2-b1-a', 'wd'])

      organised[7].should eq(['b1', 'q3', 'Error', 'q3-b1-a', 'fwe'])
      organised[8].should eq(['b1', 'q3', 'Error', 'q3-b1-a', 'fwf'])

      organised[9].should eq(['b2', 'q1', 'Error', 'q1-b2-a', 'fwa'])
      organised[10].should eq(['b2', 'q1', 'Warning', 'q1-b2-a', 'wa'])

      organised[11].should eq(['b2', 'q2', 'Error', 'q2-b2-a', 'fwc'])
      organised[12].should eq(['b2', 'q2', 'Error', 'q2-b2-a', 'fwd'])
      organised[13].should eq(['b2', 'q2', 'Warning', 'q2-b2-a', 'wd'])

      organised[14].should eq(['b2', 'q3', 'Warning', 'q3-b2-a', 'we'])
    end
  end
end