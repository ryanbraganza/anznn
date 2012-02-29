class BatchDetailReportGenerator

  def self.generate_report(organiser, file_path)
    CSV.open(file_path, "wb") do |csv|
      csv.add_row ['BabyCode', 'Column Name', 'Type', 'Value', 'Message']
      organiser.detailed_problems.each do |entry|
        csv.add_row entry
      end
    end
  end
end