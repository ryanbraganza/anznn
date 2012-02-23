class DateInputHandler

  def initialize(input)
    if input.is_a?(String)
      handle_string(input)
    elsif input.is_a?(Hash)
      handle_hash(input)
    elsif input.is_a?(Date)
      @valid = true
      @date = input
    else
      raise "DateInputHandler can only handle String, Hash and Date input"
    end
  end

  def valid?
    @valid
  end

  def to_date
    raise "Date is not valid, cannot call to_date, you should check valid? first" unless @valid
    @date
  end

  def to_raw
    raise "Date is valid, cannot call to_raw, you should check valid? first" if @valid
    @raw
  end

  private

  def handle_hash(input)
    if input[:day].blank? || input[:month].blank? || input[:year].blank?
      @raw = input
      @valid = false
    else
      begin
        @date = Date.civil input[:year].to_i, input[:month].to_i, input[:day].to_i
        @valid = true
      rescue ArgumentError
        @raw = input
        @valid = false
      end
    end
  end

  def handle_string(input)
    begin
      #try yyyy-mm-dd format
      @date = Date.strptime(input, "%Y-%m-%d")
      @valid = true
    rescue ArgumentError
      begin
        #try dd/mm/yyyy format
        @date = Date.strptime(input, "%d/%m/%Y")
        @valid = true
      rescue ArgumentError
        @raw = input
        @valid = false
      end
    end

    #sanity check - reject years less than 1900
    if @valid && @date.year < 1900
      @valid = false
      @raw = input
      @date = nil
    end
  end
end