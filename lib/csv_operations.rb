module CsvOperations
  def read_hashes_from_csv(file_name)
    csv_data = CSV.read(file_name)
    headers = csv_data.shift.map { |i| i.to_s }
    string_data = csv_data.map { |row| row.map { |cell| cell.to_s } }
    string_data.map { |row| Hash[*headers.zip(row).flatten] }
  end
end
