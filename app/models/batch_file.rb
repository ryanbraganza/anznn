class BatchFile < ActiveRecord::Base

  belongs_to :survey
  belongs_to :user

  has_attached_file :file, :styles => {}, :path => :make_file_path

  validates_presence_of :survey_id
  validates_presence_of :user_id
  validates_presence_of :file_file_name

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/:id.:extension"
  end
end
