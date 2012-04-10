class CsvGenerator

  attr_accessor :survey_id, :hospital_id, :year_of_registration, :records, :survey

  def initialize(survey_id, hospital_id, year_of_registration)
    self.survey_id = survey_id
    self.hospital_id = hospital_id
    self.year_of_registration = year_of_registration

    self.survey = Survey.find(survey_id)

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
      csv.add_row %w(Survey YearOfRegistration Hospital BabyCode)
      records.each do |entry|
        csv.add_row [entry.survey.name, entry.year_of_registration, entry.hospital.abbrev, entry.baby_code]
      end
    end
  end
end