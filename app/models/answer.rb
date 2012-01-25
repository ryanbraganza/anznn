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
          raise "Decimal qn type Not Implemented"
        when 'Integer'
          raise "Integer qn type Not Implemented"
        else
          raise "Question type not recognised!"
      end
    end

  end
end
