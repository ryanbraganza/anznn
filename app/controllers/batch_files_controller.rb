class BatchFilesController < ApplicationController

  UPLOAD_NOTICE = "Your upload has been received and is now being processed. This may take some time depending on the size of the file. The status of your uploads can be seen in the table below. You will need to refresh the page to see an updated status."
  before_filter :authenticate_user!

  load_and_authorize_resource

  def new
  end

  def create
    @batch_file.user = current_user
    @batch_file.hospital = current_user.hospital
    if @batch_file.save
      @batch_file.delay.process
      redirect_to root_path, notice: UPLOAD_NOTICE
    else
      render :new
    end
  end
end
