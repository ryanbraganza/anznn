class BatchFile < ActiveRecord::Base

  belongs_to :survey
  belongs_to :user

  validates_presence_of :survey_id
  validates_presence_of :user_id

  has_attached_file :file, :styles => {}, :path => :make_file_path

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/:id.:extension"
  end
end
