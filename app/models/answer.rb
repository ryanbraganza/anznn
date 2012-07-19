class Answer < ActiveRecord::Base

  #Answer abstracts all of the hard work of storing and retrieving answers.
  #Because of this, you should only use the interface methods rather than poking around in the fields themselves:
  # The answer, regardless of type is stored and read from the #answer_value field
  # If that answer generates a warning, it can be discovered through #has_warning? and read through #warnings

  TYPE_CHOICE = 'Choice'
  TYPE_DATE = 'Date'
  TYPE_DECIMAL = 'Decimal'
  TYPE_INTEGER = 'Integer'
  TYPE_TEXT = 'Text'
  TYPE_TIME = 'Time'
  #Used for invalid / unset question types
  TYPE_ERROR = nil

  belongs_to :question
  belongs_to :response

  validates_presence_of :question
  validates_presence_of :response
  validate :mutually_exclusive_columns_are_blank

  serialize :raw_answer

  def has_warning?
    warnings.present? or fatal_warnings.present?
  end

  def has_fatal_warning?
    fatal_warnings.present?
  end

  def answer_value_set?
    persisted? || answer_value_set
  end

  def fatal_warnings
    if answer_value_set?
      [warn_on_invalid_data, *warn_on_cross_questions].compact
    else
      []
    end
  end

  def warnings
    if answer_value_set?
      [warn_on_range].compact
    else
      []
    end
  end

  def violates_mandatory
    question.mandatory and !answer_value_set?
  end

  def format_for_display
    return "" unless raw_answer.nil? #don't show anything if its a dodgy answer
    case question.question_type
      when TYPE_TEXT, TYPE_DECIMAL, TYPE_INTEGER
        answer_value.nil? ? "Not answered" : answer_value.to_s
      when TYPE_DATE
        date_answer.nil? ? "Not answered" : date_answer.strftime('%d/%m/%Y')
      when TYPE_TIME
        time_answer.nil? ? "Not answered" : time_answer.strftime('%H:%M')
      when TYPE_CHOICE
        if answer_value.nil?
          "Not answered"
        else
          qo = question.question_options.find { |qo| qo.option_value == self.answer_value }
          qo ? qo.display_value : "Not answered"
        end
      else
        raise "Unknown question type #{question.question_type}"
    end
  end

  def format_for_csv
    return raw_answer unless raw_answer.nil?
    case question.question_type
      when TYPE_TEXT, TYPE_DECIMAL, TYPE_INTEGER, TYPE_CHOICE
        answer_value.to_s
      when TYPE_DATE
        date_answer.strftime('%Y-%m-%d')
      when TYPE_TIME
        time_answer.strftime('%H:%M')
      else
        raise "Unknown question type #{question.question_type}"
    end
  end

  def answer_value=(val)
    question_type = self.question.present? ? self.question.question_type : TYPE_ERROR
    sanitise_and_write_input val, question_type
    self.answer_value_set = true
  end

  def answer_value
    #If there is a value in raw_answer we can just use that and ignore everything else
    unless self.raw_answer.blank?
      ans_val = self.raw_answer
      if ans_val.is_a?(Hash)
        #Convert the hash to a PartialDateTimeHash so we get the helper methods
        ans_val = PartialDateTimeHash.new(ans_val)
      end
      return ans_val
    end
    #alias_method :get_answer_value, :answer_value

    #If not then lets assign the correct value
    qn_type = self.question.question_type

    case qn_type
      when TYPE_TEXT
        self.text_answer
      when TYPE_DATE
        self.date_answer
      when TYPE_TIME
        self.time_answer
      when TYPE_CHOICE
        self.choice_answer
      when TYPE_DECIMAL
        self.decimal_answer
      when TYPE_INTEGER
        self.integer_answer
      else
        nil
    end
  end

  def answer_with_offset(offset)
    return nil unless self.raw_answer.blank?
    return nil if self.answer_value.blank?
    qn_type = self.question.question_type

    case qn_type
      when TYPE_TEXT
        self.text_answer # Offset not applicable
      when TYPE_DATE
        self.date_answer + offset
      when TYPE_TIME
        self.time_answer + offset
      when TYPE_CHOICE
        self.choice_answer.to_i + offset
      when TYPE_DECIMAL
        self.decimal_answer + offset
      when TYPE_INTEGER
        self.integer_answer + offset
      else
        nil
    end

  end

  def comparable_answer
    answer_with_offset(0)
  end

  private

  attr_accessor :answer_value_set

  def mutually_exclusive_columns_are_blank
    # A lazy way to work out if more than one of the data columns are set.
    set_columns = 0
    set_columns += text_answer.present? ? 1 : 0
    set_columns += date_answer.present? ? 1 : 0
    set_columns += time_answer.present? ? 1 : 0
    set_columns += integer_answer.present? ? 1 : 0
    set_columns += decimal_answer.present? ? 1 : 0
    set_columns += raw_answer.present? ? 1 : 0

    return false unless set_columns <= 1
  end

  def warn_on_invalid_data
    if raw_answer.present?
      case self.question.question_type
        when TYPE_DATE
          if raw_answer.is_a?(String)
            "Answer is invalid (must be a valid date)"
          elsif raw_answer[:day].present? && raw_answer[:month].present? && raw_answer[:year].present?
            "Answer is invalid (Provided date does not exist)"
          else
            "Answer is incomplete (one or more fields left blank)"
          end
        when TYPE_TIME
          raw_answer.is_a?(String) ? "Answer is invalid (must be a valid time)" : "Answer is incomplete (a field was left blank)"
        when TYPE_DECIMAL
          "Answer is the wrong format (Expected a decimal value)"
        when TYPE_INTEGER
          "Answer is the wrong format (Expected an integer)"
        else
          "Answer contains invalid data"
      end
    else
      if self.question.question_type == Question::TYPE_CHOICE
        #this should only ever be triggered by batch processing
        allowed_values = question.question_options.collect(&:option_value)
        "Answer must be one of #{allowed_values.inspect}" unless allowed_values.include?(choice_answer)
      end
    end
  end

  def warn_on_cross_questions
    CrossQuestionValidation.check self
  end

  def warn_on_range
    if question.type_text?
      (passed, message) = StringLengthValidator.validate(question, self.text_answer)
      return message unless passed
    elsif question.type_decimal?
      (passed, message) = NumberRangeValidator.validate(question, self.decimal_answer)
      return message unless passed
    elsif question.type_integer?
      (passed, message) = NumberRangeValidator.validate(question, self.integer_answer)
      return message unless passed
    end
    nil
  end

  def sanitise_and_write_input (input, question_type)
    clear_fields

    begin
      if input.nil? then
        raise InputError
      end
      case question_type
        when TYPE_TEXT
          self.text_answer = input
        when TYPE_DATE
          input_handler = DateInputHandler.new(input)
          if input_handler.valid?
            self.date_answer = input_handler.to_date
          else
            self.raw_answer = input_handler.to_raw
          end
        when TYPE_TIME
          input_handler = TimeInputHandler.new(input)
          if input_handler.valid?
            self.time_answer = input_handler.to_time
          else
            self.raw_answer = input_handler.to_raw
          end
        when TYPE_CHOICE
          self.choice_answer = input
        when TYPE_DECIMAL
          if input.blank?
            self.decimal_answer = nil
          else
            Float(input) #This is used to see if the number can be expressed as a decimal - BigDecimal won't raise any exceptions
            self.decimal_answer = input
          end
        when TYPE_INTEGER
          if input.blank?
            self.integer_answer = nil
          else
            int = Integer(input)
            self.integer_answer = int
          end
        when TYPE_ERROR
          raise InputError
        else
          raise "Question type not recognised!"
      end
    rescue ArgumentError
      self.raw_answer = input

    end
  end

  def clear_fields
    self.text_answer = nil
    self.date_answer = nil
    self.time_answer = nil
    self.choice_answer = nil
    self.decimal_answer = nil
    self.integer_answer = nil
    self.raw_answer = nil
  end


end
