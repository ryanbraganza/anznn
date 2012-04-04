class StatsReport

  attr_accessor :survey, :counts, :years

  def initialize(survey)
    self.survey = survey
    self.counts = Response.count(conditions: {survey_id: survey.id}, group: [:year_of_registration, :submitted_status, :hospital_id])
    self.years = Response.for_survey(survey).select("distinct year_of_registration").collect(&:year_of_registration).sort
  end

  def response_count(year_of_registration, submitted_status, hospital_id)
    # counts will be a hash with keys: [year_of_reg, submitted_status, hospital_id], values: the count
    counts[[year_of_registration, submitted_status, hospital_id]] || "none"
  end

  def empty?
    Response.for_survey(survey).count == 0
  end
end