class PartialDateTimeHash < HashWithIndifferentAccess

  fields = [:day, :month, :year, :hour, :min]

  fields.each do |method_name|
    send :define_method, method_name do
      self[method_name].blank? ? nil : self[method_name].to_i
    end
  end

end

