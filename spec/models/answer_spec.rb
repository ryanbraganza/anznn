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
    let(:text_question) { Factory(:question, question_type: Question::TYPE_TEXT) }
    let(:integer_question) { Factory(:question, question_type: Question::TYPE_INTEGER) }
    let(:decimal_question) { Factory(:question, question_type: Question::TYPE_DECIMAL) }
    let(:text_answer) { Factory(:answer, question: text_question, text_answer: "blah") }
    let(:integer_answer) { Factory(:answer, question: integer_question, integer_answer: 34) }
    let(:decimal_answer) { Factory(:answer, question: decimal_question, decimal_answer: 1.13) }

    describe "Should call the string length validator if question type is text" do
      it "should record the warning if validation fails" do
        StringLengthValidator.should_receive(:validate).with(text_question, "blah").and_return([false, "My string warning"])
        text_answer.warning.should be_nil
        text_answer.compute_warnings
        text_answer.warning.should eq("My string warning")
      end
    end

    describe "Should call the number validator if question type is integer" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).with(integer_question, 34).and_return([false, "My integer warning"])
        integer_answer.warning.should be_nil
        integer_answer.compute_warnings
        integer_answer.warning.should eq("My integer warning")
      end
    end

    describe "Should call the number validator if question type is decimal" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).with(decimal_question, 1.13).and_return([false, "My decimal warning"])
        decimal_answer.warning.should be_nil
        decimal_answer.compute_warnings
        decimal_answer.warning.should eq("My decimal warning")
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
      it "saves an integer as a decimal" do
        a = Answer.new
        a.sanitise_input('123', 'Decimal')
        a.decimal_answer.should eq 123
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
