class Answer < ActiveRecord::Base
  belongs_to :question
  belongs_to :response

  validates_presence_of :question
  validates_presence_of :response

  def sanitise_input(answer_value, question_type)
    begin
      case question_type
        when 'Text'
          self.text_answer = answer_value
        when 'Date'
          self.date_answer =
            begin
              Date.civil answer_value["year"].to_i, answer_value["month"].to_i, answer_value["day"].to_i
            rescue ArgumentError
              nil #TODO this is a validation failure (or blank?)
            end
        when 'Time'
          self.time_answer =
            begin
              if answer_value["hour"].blank? || answer_value["min"].blank?
                nil
              else
                Time.utc 2000,1,1, answer_value["hour"].to_i, answer_value["min"].to_i
              end
            rescue ArgumentError
              nil #TODO this is a validation failure (or blank?)
            end
        when 'Choice'
          raise "Choice qn type Not Implemented"
        when 'Decimal'
          float = answer_value.to_f
          if float.to_s == answer_value
            self.decimal_answer = float
          elsif answer_value.empty?
            self.decimal_answer = nil
          end
        when 'Integer'
          int = answer_value.to_i
          if int.to_s == answer_value
            self.integer_answer = int
          elsif answer_value.empty?
            self.integer_answer = nil
          end
        else
          raise "Question type not recognised!"
      end
    end
  end

  attr_accessor :warning

  def compute_warnings
    if question.type_text?
      passed, message = StringLengthValidator.validate(question, self.text_answer)
      self.warning = message unless passed
    elsif question.type_decimal?
      passed, message = NumberRangeValidator.validate(question, self.decimal_answer)
      self.warning = message unless passed
    elsif question.type_integer?
      passed, message = NumberRangeValidator.validate(question, self.integer_answer)
      self.warning = message unless passed
    end
  end

  def has_warning?
    !self.warning.blank?
  end
end
