require 'csv'

class BatchFile < ActiveRecord::Base

  STATUS_FAILED = "Failed"
  STATUS_SUCCESS = "Processed successfully"
  STATUS_FAILED_INVALID_FILE = "Failed - invalid file"

  belongs_to :survey
  belongs_to :user
  belongs_to :hospital

  has_attached_file :file, :styles => {}, :path => :make_file_path

  before_validation :set_status

  validates_presence_of :survey_id
  validates_presence_of :user_id
  validates_presence_of :hospital_id
  validates_presence_of :file_file_name

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/:id.:extension"
  end

  def process

    begin
      failures = false
      responses = []
      logger.info("Processing batch file with id #{id}")
      CSV.foreach(file.path, {headers: true}) do |row|
        logger.info("Processing row #{row}")
        unless row.headers.include?("BabyCode")
          self.status = STATUS_FAILED_INVALID_FILE
          save!
          return
        end
        baby_code = row["BabyCode"]
        if baby_code.blank?
          failures = true
        else
          response = Response.new(survey: survey, baby_code: baby_code, user: user, hospital: hospital)
          response.build_answers_from_hash(row.to_hash)
          failures = true unless response.no_errors_or_warnings?
          responses << response
        end
      end
      self.status = failures ? STATUS_FAILED : STATUS_SUCCESS
      unless failures
        responses.each { |r| r.save! }
      end
      save!
    rescue ArgumentError
      logger.info("Argument error while reading file")
      # TODO: Catching ArgumentError seems a bit odd, but CSV throws it when the file is not UTF-8 which happens if you upload an xls file
      self.status = STATUS_FAILED_INVALID_FILE
      save!
    rescue CSV::MalformedCSVError
      logger.info("Malformed CSV error while reading file")
      self.status = STATUS_FAILED_INVALID_FILE
      save!
    end
    logger.info("Finished processing file with id #{id}, status is now #{status}")
  end

  private
  def set_status
    self.status = "In Progress" if self.status.nil?
  end

end
