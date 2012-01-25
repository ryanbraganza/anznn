require 'spec_helper'

describe Answer do
  describe "Associations" do
    it { should belong_to :question }
    it { should belong_to :response }
  end
  describe "Validations" do
    it { should validate_presence_of :question }
    it { should validate_presence_of :response }
  end

  describe "Validating for warnings" do
    let(:question) { Factory(:question, question_type: Question::TYPE_TEXT) }
    let(:answer) { Factory(:answer, question: question, text_answer: "blah") }

    describe "Should call the string length validator if question type is text" do
      it "should record the warning if validation fails" do
        StringLengthValidator.should_receive(:validate).with(question, "blah").and_return([false, "My string warning"])
        answer.warning.should be_nil
        answer.compute_warnings
        answer.warning.should eq("My string warning")
      end
      it "should record no warning if validation passes" do
        StringLengthValidator.should_receive(:validate).with(question, "blah").and_return([true, "I don't belong here'"])
        answer.warning.should be_nil
        answer.compute_warnings
        answer.warning.should be_nil
      end
    end
  end
end
