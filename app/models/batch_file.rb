require 'csv'

class BatchFile < ActiveRecord::Base

  belongs_to :survey
  belongs_to :user

  has_attached_file :file, :styles => {}, :path => :make_file_path

  before_validation :set_status

  validates_presence_of :survey_id
  validates_presence_of :user_id
  validates_presence_of :file_file_name

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/:id.:extension"
  end

  def process
    begin
      CSV.foreach(file.path, {headers: true}) do |row|
        unless row.headers.include?("BabyCode")
          self.status = "Failed - invalid file"
          save!
          return
        end
      end
    rescue ArgumentError
      # TODO: Catching ArgumentError seems a bit odd, but CSV throws it when the file is not UTF-8 which happens if you upload an xls file
      self.status = "Failed - invalid file"
      save!
    rescue CSV::MalformedCSVError
      self.status = "Failed - invalid file"
      save!
    end
  end


  private
  def set_status
    self.status = "In Progress" if self.status.nil?
  end

end
