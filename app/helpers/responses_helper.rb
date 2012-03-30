module ResponsesHelper
  
  def response_title(response)
    "#{response.survey.name} - Baby Code #{response.baby_code} - Year of Registration #{response.year_of_registration}"
  end
end
