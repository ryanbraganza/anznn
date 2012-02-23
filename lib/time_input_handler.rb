class TimeInputHandler
  def initialize(input)
    if input.is_a?(String)
      handle_string(input)
    elsif input.is_a?(Hash)
      handle_hash(input)
    elsif input.is_a?(Time)
      @valid = true
      @time = input
    else
      raise "TimeInputHandler can only handle String, Hash and Time input"
    end
  end

  def valid?
    @valid
  end

  def to_time
    raise "Time is not valid, cannot call to_time, you should check valid? first" unless @valid
    @time
  end

  def to_raw
    raise "Time is valid, cannot call to_raw, you should check valid? first" if @valid
    @raw
  end

  private

  def handle_hash(input)
    if input[:hour].blank? || input[:min].blank?
      @raw = input
      @valid = false
    else
      begin
        @time = Time.utc(2000, 1, 1, input[:hour].to_i, input[:min].to_i)
        @valid = true
      rescue ArgumentError
        @raw = input
        @valid = false
      end
    end
  end

  def handle_string(input)
    begin
      t = Time.strptime(input, "%H:%M")
      #strptime accepts 24:00 which we don't want because its kinda ambiguous, so we have to check for it ourselves
      if input.split(":").first == "24"
        @raw = input
        @valid = false
      else
        @time = Time.utc(2000, 1, 1, t.hour, t.min)
        @valid = true
      end
    rescue ArgumentError
      @raw = input
      @valid = false
    end
  end

end