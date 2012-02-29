class PartialDateTimeHash < HashWithIndifferentAccess
  #So rails' black magic with dates and times sucks. Fortunately, if you give the helper methods something that looks
  # like a Date or Time and quacks like one then it will work like one.

  #This hash can be built by passing it a Date, Time, DateTime or regular hash
  #Warning - this will IGNORE the day/month/year for a Time object. use DateTime instead!!!

  fields = [:day, :month, :year, :hour, :min]

  fields.each do |method_name|
    send :define_method, method_name do
      self[method_name].blank? ? nil : self[method_name].to_i
    end
  end

  def initialize(input)
    if input.is_a?(Date)
      super({day: input.day, month: input.month, year: input.year})
    elsif input.is_a?(Time)
      super({min: input.min, hour: input.hour})
    elsif input.is_a?(DateTime)
      super({min: input.min, hour: input.hour, day: input.day, month: input.month, year: input.year})
    else
      super(input)
    end
  end

end