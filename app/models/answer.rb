class Answer < ActiveRecord::Base

  #Answer abstracts all of the hard work of storing and retrieving answers.
  #Because of this, you should only use the interface methods rather than poking around in the fields themselves:
  # The answer, regardless of type is stored and read from the #answer_value field
  # If that answer generates a warning, it can be discovered through #has_warning? and read through #warning
  # - AB 2012-02-01

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

  after_find :compute_warnings
  #after_find :set_answer_value
  #before_validation :sanitise_input

  attr_accessor :warning

  serialize :raw_answer

  def has_warning?
    !self.warning.blank?
  end

  def format_for_display
    case question.question_type
      when TYPE_TEXT
        self.text_answer.blank? ? "Not answered" : self.text_answer
      when TYPE_DATE
        self.date_answer.nil? ? "Not answered" : self.date_answer.strftime('%d/%m/%Y')
      when TYPE_TIME
        self.time_answer.nil? ? "Not answered" : self.time_answer.strftime('%H:%M')
      when TYPE_CHOICE
        if self.choice_answer.nil?
          "Not answered"
        else
          qo = question.question_options.where(option_value: self.choice_answer).first
          qo ? qo.display_value : "Not answered"
        end
      when TYPE_DECIMAL
        self.decimal_answer.nil? ? "Not answered" : self.decimal_answer.to_s
      when TYPE_INTEGER
        self.integer_answer.nil? ? "Not answered" : self.integer_answer.to_s
      else
        nil
    end
  end

  def answer_value=(val)
    question_type = self.question.present? ? self.question.question_type : TYPE_ERROR
    sanitise_and_write_input val, question_type
    compute_warnings
  end

  def answer_value
    #If there is a value in raw_answer we can just use that and ignore everything else
    unless self.raw_answer.blank?
      ans_val = self.raw_answer
      if ans_val.is_a?(Hash)
        #By Convert the hash to a PartialDateTimeHash so we get the helper methods
        ans_val = PartialDateTimeHash.new(ans_val)
      end
      return ans_val
    end
    #alias_method :get_answer_value, :answer_value

    #If not then lets assign the correct value
    qn_type = self.question.question_type
    return case qn_type
             when TYPE_TEXT
               self.text_answer
             when TYPE_DATE
               #The only reason why this is converted to a PDTH rather than left as a Date object is because
               #The object that goes in to this model should be of the same type as the one that comes out - ie you
               # shouldn't put in a hash and get out a date.
               # If for some reason the PDTH doesn't meet requirements and can't be extended, then you should be
               # able to revert back to a Date without breaking too much. Good luck!
               PartialDateTimeHash.new self.date_answer
             when TYPE_TIME
               # See above
               PartialDateTimeHash.new self.time_answer
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

  private

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

  def compute_warnings
    # At this stage, we're only taking the highest priority warning.
    # This behaviour would be fairly easy to change however
    self.warning = warn_on_invalid_data || warn_on_range || warn_on_cross_questions
  end

  def warn_on_invalid_data
    if raw_answer.present?
      case self.question.question_type
        when TYPE_DATE
          if raw_answer[:day].present? && raw_answer[:month].present? && raw_answer[:year].present?
            "Answer is invalid (Provided date does not exist)"
          else
            "Answer is incomplete (one or more fields left blank)"
          end
        when TYPE_TIME
          "Answer is incomplete (a field was left blank)"
        when TYPE_DECIMAL
          "Answer is the wrong format (Expected a decimal value)"
        when TYPE_INTEGER
          "Answer is the wrong format (Expected an integer)"
        else
          "Answer contains invalid data"
      end
    else
      nil
    end
  end

  def warn_on_cross_questions
    warnings = CrossQuestionValidation.check self
    warnings.first
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
          if input.is_a? Date
            self.date_answer = input
          else
            self.date_answer =
              if input[:day].blank? || input[:month].blank? || input[:year].blank?
                raise ArgumentError
              else
                Date.civil input[:year].to_i, input[:month].to_i, input[:day].to_i
              end
          end
        when TYPE_TIME
          self.time_answer =
              if input[:hour].blank? || input[:min].blank?
                raise ArgumentError
              else
                Time.utc 2000, 1, 1, input[:hour].to_i, input[:min].to_i
              end
        when TYPE_CHOICE
          self.choice_answer = input
        when TYPE_DECIMAL
          if input.blank?
            self.decimal_answer = nil
          else
            float = Float(input)
            self.decimal_answer = float
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
