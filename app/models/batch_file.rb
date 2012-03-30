require 'csv'

class BatchFile < ActiveRecord::Base

  BABY_CODE_COLUMN = "BabyCode"
  STATUS_FAILED = "Failed"
  STATUS_SUCCESS = "Processed Successfully"
  STATUS_REVIEW = "Needs Review"
  STATUS_IN_PROGRESS = "In Progress"

  MESSAGE_WARNINGS = "The file you uploaded has one or more warnings. Please review the reports for details."
  MESSAGE_NO_BABY_CODE = "The file you uploaded did not contain a BabyCode column"
  MESSAGE_MISSING_BABY_CODES = "The file you uploaded is missing one or more baby codes. Each record must have a baby code."
  MESSAGE_EMPTY = "The file you uploaded did not contain any data"
  MESSAGE_FAILED_VALIDATION = "The file you uploaded did not pass validation. Please review the reports for details."
  MESSAGE_SUCCESS = "Your file has been processed successfully"
  MESSAGE_BAD_FORMAT = "The file you uploaded was not a valid CSV file"
  MESSAGE_DUPLICATE_BABY_CODES = "The file you uploaded contained duplicate baby codes. Each baby code can only be used once."

  belongs_to :survey
  belongs_to :user
  belongs_to :hospital

  has_attached_file :file, :styles => {}, :path => :make_file_path

  before_validation :set_status

  validates_presence_of :survey_id
  validates_presence_of :user_id
  validates_presence_of :hospital_id
  validates_presence_of :file_file_name

  attr_accessor :responses

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/:id.:extension"
  end

  def has_summary_report?
    !summary_report_path.blank?
  end

  def has_detail_report?
    !detail_report_path.blank?
  end

  def success?
    self.status == STATUS_SUCCESS
  end

  def force_submittable?
    status == STATUS_REVIEW
  end

  def process(force=false)
    raise "Batch has already been processed, cannot reprocess" unless status == STATUS_IN_PROGRESS or force
    raise "Can't force with status #{status}" unless !force or force_submittable?
    BatchFile.transaction do
      begin
        can_generate_report = process_batch(force)
        if can_generate_report
          BatchReportGenerator.new(self).generate_reports
        end
      rescue ArgumentError
        logger.info("Argument error while reading file")
        # Note: Catching ArgumentError seems a bit odd, but CSV throws it when the file is not UTF-8 which happens if you upload an xls file
        set_outcome(STATUS_FAILED, MESSAGE_BAD_FORMAT)
      rescue CSV::MalformedCSVError
        logger.info("Malformed CSV error while reading file")
        set_outcome(STATUS_FAILED, MESSAGE_BAD_FORMAT)
      end
      save!
      logger.info("Finished processing file with id #{id}, status is now #{status}")
    end
  end

  def problem_record_count
    return nil if responses.nil?
    responses.collect { |r| r.warnings? || !r.valid? }.count(true)
  end

  def organised_problems
    organiser = QuestionProblemsOrganiser.new

    # get all the problems from all the responses organised for reporting
    responses.each do |r|
      r.answers.each do |answer|
        organiser.add_problems(answer.question.code, r.baby_code, answer.fatal_warnings, answer.warnings, answer.format_for_batch_report)
      end
      r.missing_mandatory_questions.each do |question|
        organiser.add_problems(question.code, r.baby_code, ["This question is mandatory"], [], "")
      end
      r.valid? #we have to call this to trigger errors getting populated
      organiser.add_problems("BabyCode", r.baby_code, r.errors.full_messages, [], r.baby_code) unless r.errors.empty?
    end
    organiser
  end

  private

  def process_batch(force)
    logger.info("Processing batch file with id #{id}")

    passed_pre_processing = pre_process_file
    unless passed_pre_processing
      save!
      return
    end

    count = 0
    failures = false
    warnings = false
    responses = []
    CSV.foreach(file.path, {headers: true}) do |row|
      count += 1
      baby_code = row[BABY_CODE_COLUMN]
      #TODO placeholder year of reg until we implement that for batches
      response = Response.new(survey: survey, baby_code: baby_code, user: user, hospital: hospital, year_of_registration: 2005, submitted_status: Response::STATUS_UNSUBMITTED, batch_file: self)
      response.build_answers_from_hash(row.to_hash)

      failures = true if (response.fatal_warnings? || !response.valid?)
      warnings = true if response.warnings?
      responses << response
    end

    self.record_count = count
    if failures
      set_outcome(STATUS_FAILED, MESSAGE_FAILED_VALIDATION)
    elsif warnings and !force
      set_outcome(STATUS_REVIEW, MESSAGE_WARNINGS)
    else
      responses.each do |r|
        r.submitted_status = Response::STATUS_SUBMITTED
        r.save!
      end
      set_outcome(STATUS_SUCCESS, MESSAGE_SUCCESS)
    end
    save!
    self.responses = responses #this is only ever kept in memory for the sake of reporting, its not an AR association
    true
  end

  def pre_process_file
    # do basic checks that can result in the file failing completely and not being validated
    count = 0
    baby_codes = []
    CSV.foreach(file.path, {headers: true}) do |row|
      unless row.headers.include?(BABY_CODE_COLUMN)
        set_outcome(STATUS_FAILED, MESSAGE_NO_BABY_CODE)
        return false
      end
      count += 1
      baby_code = row[BABY_CODE_COLUMN]
      if baby_code.blank?
        set_outcome(STATUS_FAILED, MESSAGE_MISSING_BABY_CODES)
        return false
      else
        if baby_codes.include?(baby_code)
          set_outcome(STATUS_FAILED, MESSAGE_DUPLICATE_BABY_CODES)
          return false
        else
          baby_codes << baby_code
        end
      end
    end

    if count == 0
      set_outcome(STATUS_FAILED, MESSAGE_EMPTY)
      return false
    end

    true
  end

  def set_status
    self.status = STATUS_IN_PROGRESS if self.status.nil?
  end

  def set_outcome(status, message)
    self.status = status
    self.message = message
  end
end
