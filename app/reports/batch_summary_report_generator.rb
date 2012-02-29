class BatchSummaryReportGenerator

  def self.generate_report(batch_file, organiser, file_path)
    Prawn::Document.generate file_path do
      font_size(24)
      text "Validation Report: Summary", :align => :center

      font_size(10)

      move_down 20

      text "Survey: #{batch_file.survey.name}"
      text "File name: #{batch_file.file_file_name}"
      text "Date submitted: #{batch_file.created_at}"
      text "Submitted by: #{batch_file.user.full_name}"
      text "Status: #{batch_file.status} (#{batch_file.message})"

      move_down 10
      text "Number of records: #{batch_file.record_count}"
      text "Number of records with problems: #{batch_file.problem_record_count}"

      move_down 10
      problems_table = organiser.aggregated_by_question_and_message
      if problems_table.size > 1
        table(problems_table, :header => true, :row_colors => ["FFFFFF", "F0F0F0"]) do
          row(0).font_style = :bold
        end
      end

    end
  end
end