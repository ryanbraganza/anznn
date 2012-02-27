require 'spec_helper'

describe QuestionProblem do
  it "can have more baby codes added to it" do
    qp = QuestionProblem.new("code", "msg", "error")
    qp.question_code.should == "code"
    qp.message.should == "msg"
    qp.type.should == "error"
    qp.baby_codes.should be_empty
    qp.add_baby_code("abc")
    qp.add_baby_code("def")
    qp.baby_codes.should eq(["abc", "def"])
  end
end