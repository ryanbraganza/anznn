module ResponsesHelper
  
  def response_title(response)
    "#{response.survey.name} - Baby Code #{response.baby_code} - Year of Registration #{response.year_of_registration}"
  end

  def prep_help(text)
    simple_format(h text).html_safe
  end
end
