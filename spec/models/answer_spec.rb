require 'spec_helper'

describe Answer do
  let(:response) { Factory(:response) }
  let(:text_question) { Factory(:question, question_type: Question::TYPE_TEXT) }
  let(:integer_question) { Factory(:question, question_type: Question::TYPE_INTEGER) }
  let(:decimal_question) { Factory(:question, question_type: Question::TYPE_DECIMAL) }
  let(:date_question) { Factory(:question, question_type: Question::TYPE_DATE) }
  let(:time_question) { Factory(:question, question_type: Question::TYPE_TIME) }
  let(:choice_question) do
    cq = Factory(:question, question_type: Question::TYPE_CHOICE)
    Factory(:question_option, question: cq, option_value: '0', label: 'Dog')
    Factory(:question_option, question: cq, option_value: '1', label: 'Cat')
    Factory(:question_option, question: cq, option_value: '99', label: 'Apple')
    cq
  end

  describe "Associations" do
    it { should belong_to :response }
  end
  describe "Validations" do
    it { should validate_presence_of :question_id }
    it { should validate_presence_of :response }
  end

  describe "Validating for warnings" do
    let(:text_answer) { Factory(:answer, question: text_question, answer_value: "blah") }
    let(:integer_answer) { Factory(:answer, question: integer_question, answer_value: 34) }
    let(:decimal_answer) { Factory(:answer, question: decimal_question, answer_value: 1.13) }

    describe "Should call the string length validator if question type is text" do
      it "should record the warning if validation fails" do
        StringLengthValidator.should_receive(:validate).twice.with(text_question, "blah").and_return([false, "My string warning"])
        text_answer.has_warning?.should eq true
        text_answer.warnings.should eq ["My string warning"]
        text_answer.fatal_warnings.should eq []
      end
    end

    describe "Should call the number validator if question type is integer" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).twice.with(integer_question, 34).and_return([false, "My integer warning"])
        integer_answer.has_warning?.should eq true
        integer_answer.warnings.should eq ["My integer warning"]
        integer_answer.fatal_warnings.should eq []
      end
    end

    describe "Should call the number validator if question type is decimal" do
      it "should record the warning if validation fails" do
        NumberRangeValidator.should_receive(:validate).twice.with(decimal_question, 1.13).and_return([false, "My decimal warning"])
        decimal_answer.has_warning?.should eq true
        decimal_answer.warnings.should eq ["My decimal warning"]
        decimal_answer.fatal_warnings.should eq []
      end
    end

    describe "Cross-question validation" do
      it "should record the warning if validation fails" do
        CrossQuestionValidation.should_receive(:check).twice.and_return(['error1', 'error2'])
        answer = Factory(:answer)

        answer.should have_warning
        answer.fatal_warnings.should eq ["error1", "error2"]
        answer.warnings.should eq []
      end
    end

    describe "Validating that choice answers are one of the allowed values" do
      it "should pass when value is allowed" do
        answer = Factory(:answer, question: choice_question, answer_value: "99")
        answer.should_not have_warning
      end
      it "should fail when value is not allowed" do
        answer = Factory(:answer, question: choice_question, answer_value: "98")
        answer.fatal_warnings.should eq(['Answer must be one of ["0", "1", "99"]'])
        answer.should have_warning
      end
    end
  end

  describe "comparable_answer should always return answers that can be compared using standard operators (<, >, ==, != etc)" do
    describe "answer_with_offset" do
      it "should return a comparable answer with an added offset" do
        q_choice = Factory(:answer, question: choice_question, answer_value: "98")
        q_dec = Factory(:answer, question: decimal_question, answer_value: "98")
        q_s = Factory(:answer, question: text_question, answer_value: "98")
        q_s2 = Factory(:answer, question: text_question, answer_value: "98")
        q_i = Factory(:answer, question: integer_question, answer_value: "98")
        q_date = Factory(:answer, question: date_question, answer_value: Date.today)
        q_time = Factory(:answer, question: time_question, answer_value: Time.now)

        #some select cases. the key thing is that they don't explode (but the logic should also never break)
        (q_choice.answer_with_offset(-1) < q_i.answer_with_offset(0)).should be_true
        (q_choice.answer_with_offset(-1) > q_i.answer_with_offset(0)).should be_false
        (q_choice.answer_with_offset(-1) < q_dec.answer_with_offset(0)).should be_true
        (q_choice.answer_with_offset(-1) > q_dec.answer_with_offset(0)).should be_false

        #offsets ignored for strings
        (q_s.answer_with_offset(45345) == q_s2.answer_with_offset(-2342323)).should be_true
        (q_s.answer_with_offset(45345) != q_s2.answer_with_offset(-2342323)).should be_false

        (q_date.answer_with_offset(1) > q_date.answer_with_offset(0)).should be_true
        (q_date.answer_with_offset(1) < q_date.answer_with_offset(0)).should be_false

        (q_time.answer_with_offset(1) > q_time.answer_with_offset(0)).should be_true
        (q_time.answer_with_offset(1) < q_time.answer_with_offset(0)).should be_false
      end

    end

    describe "comparable_answer" do
      it "should return comparable forms of everything" do
        #covered in answer_with_offset
      end
    end
  end

  describe "accept and sanitise all input (via assignment of answer_value), and have a warning if invalid" do
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
      it "saves invalid input as 'raw input' and has a warning" do
        a = Answer.new(question: decimal_question)
        a.answer_value = '1.23f'
        a.decimal_answer.should be_false
        a.raw_answer.should eq '1.23f'
        a.has_warning?.should be_true

      end
      # The answer record should be culled if it becomes empty, but if it gets left behind it should be blank.
      it "nils out on empty string" do
        a = Factory(:answer, question: decimal_question, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.answer_value = ''
        a.decimal_answer.should be_false
        a.raw_answer.should be_false
      end
      it "does not nil out on invalid input, and has a warning" do
        a = Factory(:answer, question: decimal_question, decimal_answer: 1.23)
        a.decimal_answer.should eq 1.23

        a.answer_value = 'garbage'
        a.decimal_answer.should be_false
        a.raw_answer.should eq 'garbage'
        a.has_warning?.should be_true

      end
    end
    describe "Integer" do

      it "saves an integer as an integer" do
        a = Answer.new(question: integer_question)
        a.answer_value = '1234'
        a.integer_answer.should eq 1234
      end
      it "saves invalid input as 'raw input' and has a warning" do
        a = Answer.new(question: integer_question)
        a.answer_value = '1234d'
        a.raw_answer.should eq '1234d'
        a.has_warning?.should be_true

      end
      it "nils out on empty string" do
        a = Factory(:answer, question: integer_question, integer_answer: 123)
        a.integer_answer.should eq 123

        a.answer_value = ''
        a.integer_answer.should be_false
        a.raw_answer.should be_false
      end
      # The answer record should be culled if it becomes empty, but if it gets left behind it should be blank.
      it "does not nil out on invalid input and shows a warning" do
        a = Factory(:answer, question: integer_question, integer_answer: 123)
        a.integer_answer.should eq 123

        a.answer_value = 'garbage'
        a.integer_answer.should be_false
        a.raw_answer.should eq 'garbage'
        a.has_warning?.should be_true

      end
    end

    describe "For date questions, should delegate to DateInputHandler to process the input" do
      it "should set the date answer if the input is valid" do
        date = Date.today
        mock_ih = mock('mock input handler')
        DateInputHandler.should_receive(:new).and_return(mock_ih)
        mock_ih.should_receive(:valid?).and_return(true)
        mock_ih.should_receive(:to_date).and_return(date)
        a = Factory(:answer, question: date_question, answer_value: "abc")
        a.date_answer.should be(date)
        a.raw_answer.should be_nil
      end

      it "should set the raw answer if the input is invalid" do
        mock_ih = mock('mock input handler')
        DateInputHandler.should_receive(:new).and_return(mock_ih)
        mock_ih.should_receive(:valid?).and_return(false)
        mock_ih.should_receive(:to_raw).and_return("blah")
        a = Factory(:answer, question: date_question, answer_value: "abc")
        a.date_answer.should be_nil
        a.raw_answer.should eq("blah")
      end
    end

    describe "For time questions, should delegate to TimeInputHandler to process the input" do
      it "should set the time answer if the input is valid" do
        time = Time.now
        mock_ih = mock('mock input handler')
        TimeInputHandler.should_receive(:new).and_return(mock_ih)
        mock_ih.should_receive(:valid?).and_return(true)
        mock_ih.should_receive(:to_time).and_return(time)
        a = Factory(:answer, question: time_question, answer_value: "abc")
        a.time_answer.should be(time)
        a.raw_answer.should be_nil
      end

      it "should set the raw answer if the input is invalid" do
        mock_ih = mock('mock input handler')
        TimeInputHandler.should_receive(:new).and_return(mock_ih)
        mock_ih.should_receive(:valid?).and_return(false)
        mock_ih.should_receive(:to_raw).and_return("blah")
        a = Factory(:answer, question: time_question, answer_value: "abc")
        a.time_answer.should be_nil
        a.raw_answer.should eq("blah")
      end
    end
  end

  describe "answer_value should contain the correct data on load with valid data" do
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
      PartialDateTimeHash.new(a.answer_value).should eq(date_hash)
    end
    it "Valid time" do
      time_hash = PartialDateTimeHash.new(Time.now)
      a = Answer.new(response: response, question: time_question, answer_value: time_hash)
      a.save!; a.answer_value = nil; a.reload
      PartialDateTimeHash.new(a.answer_value).should eq(time_hash)
    end
    it "Valid decimal" do
      a = Answer.new(response: response, question: decimal_question, answer_value: "3.45")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq(3.45)
    end
    it "Valid integer" do
      a = Answer.new(response: response, question: integer_question, answer_value: "423")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq(423)
    end
    it "Valid choice" do
      a = Answer.new(response: response, question: choice_question, answer_value: "1")
      a.save!; a.answer_value = nil; a.reload
      a.answer_value.should eq("1")
    end

  end

  describe "answer_value should contain the inputted data on load with invalid data, and a warning should be present" do

    it "invalid date from a string" do
      a = Answer.create!(response: response, question: date_question, answer_value: "blah")
      a.reload
      a.answer_value.should eq("blah")
      a.has_warning?.should be_true
      a.fatal_warnings.should eq(["Answer is invalid (must be a valid date)"])
    end

    it "invalid date from a hash" do
      date_a_s_hash = ActiveSupport::HashWithIndifferentAccess.new ({day: 31, month: 2, year: 2000})
      date_hash = PartialDateTimeHash.new date_a_s_hash
      a = Answer.create!(response: response, question: date_question, answer_value: date_a_s_hash)
      a.reload
      a.answer_value.should eq(date_hash)
      a.has_warning?.should be_true
      a.fatal_warnings.should eq(["Answer is invalid (Provided date does not exist)"])
    end

    it "partial date from a hash" do
      date_a_s_hash = ActiveSupport::HashWithIndifferentAccess.new ({day: 1, year: 2000})
      date_hash = PartialDateTimeHash.new date_a_s_hash
      a = Answer.create!(response: response, question: date_question, answer_value: date_a_s_hash)
      a.reload
      a.answer_value.should eq(date_hash)
      a.has_warning?.should be_true
      a.fatal_warnings.should eq(["Answer is incomplete (one or more fields left blank)"])
    end

    it "invalid time from a string" do
      a = Answer.create!(response: response, question: time_question, answer_value: "ab:11")
      a.reload
      a.answer_value.should eq("ab:11")
      a.has_warning?.should be_true
      a.fatal_warnings.should eq(["Answer is invalid (must be a valid time)"])
    end

    it "invalid time from a hash" do
      time_a_s_hash = ActiveSupport::HashWithIndifferentAccess.new ({hour: 20, min: 61})
      time_hash = PartialDateTimeHash.new time_a_s_hash
      a = Answer.create!(response: response, question: time_question, answer_value: time_a_s_hash)
      a.reload
      a.answer_value.should eq(time_hash)
      a.has_warning?.should be_true
      a.fatal_warnings.should eq(["Answer is incomplete (a field was left blank)"])
    end

    it "partial time" do
      time_a_s_hash = ActiveSupport::HashWithIndifferentAccess.new ({hour: 20})
      time_hash = PartialDateTimeHash.new time_a_s_hash
      a = Answer.create!(response: response, question: time_question, answer_value: time_a_s_hash)
      a.reload
      a.answer_value.should eq(time_hash)
      a.fatal_warnings.should eq(["Answer is incomplete (a field was left blank)"])
    end

    it "invalid integer" do
      input = "4.5"
      a = Answer.new(response: response, question: integer_question, answer_value: input)
      a.save!; b = Answer.find(a.id); a = b
      a.answer_value.should eq(input)
      a.has_warning?.should be_true
    end

    it "invalid decimal" do
      input = "abc"
      a = Answer.new(response: response, question: decimal_question, answer_value: input)
      a.save!; b = Answer.find(a.id); a = b
      a.answer_value.should eq(input)
      a.has_warning?.should be_true
    end

  end

  describe "Formatting an answer for display" do

    it "should handle each of the data types correctly" do
      Factory(:answer, question: text_question, answer_value: "blah").format_for_display.should eq("blah")
      Factory(:answer, question: integer_question, answer_value: "14").format_for_display.should eq("14")
      Factory(:answer, question: decimal_question, answer_value: "14").format_for_display.should eq("14.0")
      Factory(:answer, question: decimal_question, answer_value: "22.5").format_for_display.should eq("22.5")
      Factory(:answer, question: decimal_question, answer_value: "22.59").format_for_display.should eq("22.59")
      Factory(:answer, question: date_question, answer_value: PartialDateTimeHash.new({day: 31, month: 12, year: 2011})).format_for_display.should eq("31/12/2011")
      Factory(:answer, question: time_question, answer_value: PartialDateTimeHash.new({hour: 18, min: 6})).format_for_display.should eq("18:06")

      Factory(:answer, question: choice_question, answer_value: "99").format_for_display.should eq("(99) Apple")
    end

    it "should handle answers that are not filled out yet" do
      Answer.new(question: text_question).format_for_display.should eq("Not answered")
      Answer.new(question: integer_question).format_for_display.should eq("Not answered")
      Answer.new(question: decimal_question).format_for_display.should eq("Not answered")
      Answer.new(question: date_question).format_for_display.should eq("Not answered")
      Answer.new(question: time_question).format_for_display.should eq("Not answered")
      Answer.new(question: choice_question).format_for_display.should eq("Not answered")
    end

    it "should return blank for answers that are invalid" do
      Answer.new(question: integer_question, raw_answer: "asdf").format_for_display.should eq("")

      Answer.new(question: decimal_question, raw_answer: "asdf").format_for_display.should eq("")

      date_as_hash = ActiveSupport::HashWithIndifferentAccess.new ({day: 1, year: 2000})
      Answer.new(question: date_question, raw_answer: PartialDateTimeHash.new(date_as_hash)).format_for_display.should eq("")

      time_as_hash = ActiveSupport::HashWithIndifferentAccess.new ({hour: 1})
      Answer.new(question: time_question, raw_answer: PartialDateTimeHash.new(time_as_hash)).format_for_display.should eq("")
    end
  end

  describe "Formatting an answer for batch file detail report" do

    it "should handle each of the data types correctly" do
      Factory(:answer, question: text_question, answer_value: "blah").format_for_csv.should eq("blah")
      Factory(:answer, question: integer_question, answer_value: "14").format_for_csv.should eq("14")
      Factory(:answer, question: decimal_question, answer_value: "14").format_for_csv.should eq("14.0")
      Factory(:answer, question: decimal_question, answer_value: "22.5").format_for_csv.should eq("22.5")
      Factory(:answer, question: decimal_question, answer_value: "22.59").format_for_csv.should eq("22.59")
      Factory(:answer, question: date_question, answer_value: "31/12/2011").format_for_csv.should eq("2011-12-31")
      Factory(:answer, question: time_question, answer_value: "18:06").format_for_csv.should eq("18:06")
      Factory(:answer, question: choice_question, answer_value: "99").format_for_csv.should eq("99")
    end

    it "should return the raw answer for answers that are invalid" do
      Answer.new(question: integer_question, raw_answer: "asdf").format_for_csv.should eq("asdf")
      Answer.new(question: decimal_question, raw_answer: "asdf").format_for_csv.should eq("asdf")
      Answer.new(question: date_question, raw_answer: "12/ff/3333").format_for_csv.should eq("12/ff/3333")
      Answer.new(question: time_question, raw_answer: "18:ab").format_for_csv.should eq("18:ab")
    end
  end

end
