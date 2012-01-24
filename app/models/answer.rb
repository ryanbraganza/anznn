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
          begin
            date = Date.civil answer_value["(1i)"].to_i, answer_value["(2i)"].to_i, answer_value["(3i)"].to_i
          rescue ArgumentError
            date = nil
          end
          self.date_answer = date
        when 'Time'
          self.time_answer = assign_multiparameter_attributes(answer_value)
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
