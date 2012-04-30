class CsvGenerator

  BASIC_HEADERS = %w(RegistrationType YearOfRegistration Hospital BabyCode)
  attr_accessor :survey_id, :hospital_id, :year_of_registration, :records, :survey, :question_codes

  def initialize(survey_id, hospital_id, year_of_registration)
    self.survey_id = survey_id
    self.hospital_id = hospital_id
    self.year_of_registration = year_of_registration

    self.survey = Survey.find(survey_id)
    self.question_codes = survey.ordered_questions.collect(&:code)

    self.records = Response.for_survey_hospital_and_year_of_registration(survey, hospital_id, year_of_registration)
  end

  def csv_filename
    name_parts = [survey.name.parameterize("_")]

    unless hospital_id.blank?
      hospital = Hospital.find(hospital_id)
      name_parts << hospital.abbrev.parameterize("_")
    end
    unless year_of_registration.blank?
      name_parts << year_of_registration
    end
    name_parts.join("_") + ".csv"
  end

  def empty?
    records.empty?
  end

  def csv
    CSV.generate(:col_sep => ",") do |csv|
      csv.add_row BASIC_HEADERS + question_codes
      records.each do |response|
        basic_row_data = [response.survey.name, response.year_of_registration, response.hospital.abbrev, response.baby_code]
        csv.add_row basic_row_data + answers(response)
      end
    end
  end

  private

  def answers(response)
    answer_hash = response.answers.reduce({}) { |hash, answer| hash[answer.question.code] = answer; hash }
    question_codes.collect do |code|
      answer = answer_hash[code]
      answer.nil? ? "" : answer.format_for_csv
    end
  end

end
