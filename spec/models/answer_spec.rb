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

  describe "sanitise_input" do
    describe "Decimal" do
      it "saves a decimal as a decimal" do
        a = Answer.new
        a.sanitise_input('1.23', 'Decimal')
        a.decimal_answer.should eq 1.23
      end
      it "does not save an invalid input" do
        a = Answer.new
        a.sanitise_input('1.23f', 'Decimal')
        a.decimal_answer.should_not be
      end
      it "nils out on empty string" do
        a = Factory(:answer, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.sanitise_input('', 'Decimal')

        a.decimal_answer.should_not be
      end
      it "does not nil out on invalid input" do
        a = Factory(:answer, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.sanitise_input('garbage', 'Decimal')

        a.decimal_answer.should eq 1.23
      end
    end
    describe "Integer" do
      it "saves an integer as an integer" do
        a = Answer.new
        a.sanitise_input('1234', 'Integer')
        a.integer_answer.should eq 1234
      end
      it "does not save an invalid integer" do
        a = Answer.new
        a.sanitise_input('1234d', 'Integer')
        a.integer_answer.should_not be
      end
      it "nils out on empty string" do
        a = Factory(:answer, integer_answer: 123)
        a.integer_answer.should eq 123

        a.sanitise_input('', 'Integer')

        a.integer_answer.should_not be
      end
      it "does not nil out on invalid input" do
        a = Factory(:answer, integer_answer: 123)
        a.integer_answer.should eq 123

        a.sanitise_input('garbage', 'Integer')

        a.integer_answer.should eq 123
      end
    end
    describe "other question types" do
      pending
    end
  end
end
