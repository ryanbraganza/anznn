class SupplementaryFile < ActiveRecord::Base
  belongs_to :batch_file
  has_attached_file :file, :styles => {}, :path => :make_file_path
  validates_presence_of :multi_name
  validates_attachment_presence :file

  def make_file_path
    # this is a method so that APP_CONFIG has been loaded by the time is executes
    "#{APP_CONFIG['batch_files_root']}/supplementary_:id.:extension"
  end

end
