class Answer < ActiveRecord::Base
  TYPE_CHOICE = 'Choice'
  TYPE_DATE = 'Date'
  TYPE_DECIMAL = 'Decimal'
  TYPE_INTEGER = 'Integer'
  TYPE_TEXT = 'Text'
  TYPE_TIME = 'Time'

  belongs_to :question
  belongs_to :response

  validates_presence_of :question
  validates_presence_of :response
  validate :mutually_exclusive_columns_are_blank

  attr_accessor :warning
  attr_accessor :answer_value

  after_find :compute_warnings
  after_find :set_answer_value
  before_validation :sanitise_input


  def has_warning?
    !self.warning.blank?
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
    self.warning =
        warn_on_required_and_blank ||
            warn_on_invalid_data ||
            warn_on_range
  end

  def warn_on_required_and_blank
    nil
  end

  def warn_on_invalid_data
    nil
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

  def set_answer_value
    if raw_answer.present?
      self.answer_value = raw_answer and return
    end

    qn_type = self.question.question_type
    self.answer_value =
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

  def sanitise_input
    qn_type = self.question.question_type
    begin
      case qn_type
        when TYPE_TEXT
          self.text_answer = self.answer_value
        when TYPE_DATE
          self.date_answer =
              begin
                Date.civil self.answer_value["year"].to_i, self.answer_value["month"].to_i, self.answer_value["day"].to_i
              rescue ArgumentError
                nil #TODO this is a validation failure (or blank?)
              end
        when TYPE_TIME
          self.time_answer =
              begin
                if self.answer_value["hour"].blank? || self.answer_value["min"].blank?
                  nil
                else
                  Time.utc 2000, 1, 1, self.answer_value["hour"].to_i, self.answer_value["min"].to_i
                end
              rescue ArgumentError
                nil #TODO this is a validation failure (or blank?)
              end
        when TYPE_CHOICE
          self.choice_answer = self.answer_value
        when TYPE_DECIMAL
          begin
            if self.answer_value.empty?
              self.decimal_answer = nil
            else
              float = Float(self.answer_value)
              self.decimal_answer = float
            end
          rescue ArgumentError
            # suppress
          end
        when TYPE_INTEGER
          begin
            if self.answer_value.empty?
              self.integer_answer = nil
            else
              int = Integer(self.answer_value)
              self.integer_answer = int
            end
          rescue ArgumentError
            # suppress
          end
        else
          raise "Question type not recognised!"
      end
    end
  end

end
