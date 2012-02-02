require 'spec_helper'

describe Answer do
  let(:response) {Factory(:response)}
  let(:text_question) { Factory(:question, question_type: Question::TYPE_TEXT) }
  let(:integer_question) { Factory(:question, question_type: Question::TYPE_INTEGER) }
  let(:decimal_question) { Factory(:question, question_type: Question::TYPE_DECIMAL) }
  let(:date_question) { Factory(:question, question_type: Question::TYPE_DATE) } # Specs missing
  let(:time_question) { Factory(:question, question_type: Question::TYPE_TIME) } # Specs missing
  let(:choice_question) { Factory(:question, question_type: Question::TYPE_CHOICE) } # Specs missing

  describe "Associations" do
    it { should belong_to :question }
    it { should belong_to :response }
  end
  describe "Validations" do
    it { should validate_presence_of :question }
    it { should validate_presence_of :response }
  end

  describe "Validating for warnings" do
    let(:text_answer) { Factory(:answer, question: text_question, answer_value: "blah") }
    let(:integer_answer) { Factory(:answer, question: integer_question, answer_value: 34) }
    let(:decimal_answer) { Factory(:answer, question: decimal_question, answer_value: 1.13) }

    describe "Should call the string length validator if question type is text" do
      it "should record the warning if validation fails" do
        StringLengthValidator.should_receive(:validate).with(text_question, "blah").and_return([false, "My string warning"])
        text_answer.has_warning?.should eq true
        text_answer.warning.should eq("My string warning")
      end
    end

    describe "Should call the number validator if question type is integer" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).with(integer_question, 34).and_return([false, "My integer warning"])
        integer_answer.has_warning?.should eq true
        integer_answer.warning.should eq("My integer warning")
      end
    end

    describe "Should call the number validator if question type is decimal" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).with(decimal_question, 1.13).and_return([false, "My decimal warning"])
        decimal_answer.has_warning?.should eq true
        decimal_answer.warning.should eq("My decimal warning")
      end
    end
  end

  describe "answer_value should contain the correct data on load" do
    it "Valid text" do
      a = Answer.new(response: response, question: text_question, answer_value: "abc")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq("abc")
    end
    it "Valid date" do
      date = Time.now.to_date
      date_hash = PartialDateTimeHash.new({day: date.day, month: date.month, year: date.year})
      a = Answer.new(response: response, question: date_question, answer_value: date_hash)
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq(date_hash)
    end
    it "Valid time" do
      time_hash = PartialDateTimeHash.new(Time.now)
      a = Answer.new(response: response, question: time_question, answer_value: time_hash)
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq(time_hash)
    end
    it "Valid decimal" do
      pending
      a = Answer.new(response: response, question: text_question, answer_value: "abc")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq("abc")
    end
    it "Valid integer" do
      pending
      a = Answer.new(response: response, question: text_question, answer_value: "abc")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq("abc")
    end
    it "Valid choice" do
      pending
      a = Answer.new(response: response, question: text_question, answer_value: "abc")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq("abc")
    end

    it "invalid text" do
      pending
    end
    it "invalid date" do
      pending
    end
    it "invalid time" do
      pending
    end

  end

  describe "sanitise input (via assignment of answer_value)" do


    describe "Decimal" do
      it "saves a decimal as a decimal" do
        a = Answer.new(question: decimal_question)
        a.answer_value = '1.23'
        a.decimal_answer.should eq 1.23
      end
      it "saves an integer as a decimal" do
        a = Answer.new(question: decimal_question)
        a.answer_value = '123'
        a.decimal_answer.should eq 123
      end
      it "saves invalid input as 'raw input'" do
        a = Answer.new(question: decimal_question)
        a.answer_value = '1.23f'
        a.decimal_answer.should_not be
        a.raw_answer.should eq '1.23f'
      end
      # The answer record should be culled if it becomes empty, but if it gets left behind it should be blank.
      it "nils out on empty string" do
        a = Factory(:answer, question: decimal_question, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.answer_value = ''
        a.decimal_answer.should_not be
        a.raw_answer.should_not be
      end
      it "does not nil out on invalid input" do
        a = Factory(:answer, question: decimal_question, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.answer_value = 'garbage'
        a.decimal_answer.should_not be
        a.raw_answer.should eq 'garbage'
      end
    end
    describe "Integer" do

      it "saves an integer as an integer" do
        a = Answer.new(question: integer_question)
        a.answer_value = '1234'
        a.integer_answer.should eq 1234
      end
      it "saves invalid input as 'raw input'" do
        a = Answer.new(question: integer_question)
        a.answer_value = '1234d'
        a.raw_answer.should eq '1234d'
      end
      it "nils out on empty string" do
        a = Factory(:answer, question: integer_question, integer_answer: 123)
        a.integer_answer.should eq 123

        a.answer_value = ''
        a.integer_answer.should_not be
        a.raw_answer.should_not be
      end
      # The answer record should be culled if it becomes empty, but if it gets left behind it should be blank.
      it "does not nil out on invalid input" do
        a = Factory(:answer, question: integer_question, integer_answer: 123)
        a.integer_answer.should eq 123

        a.answer_value = 'garbage'
        a.integer_answer.should_not be
        a.raw_answer.should eq 'garbage'
      end
    end
    describe "other question types" do
      pending
    end
  end
end
