class BatchFilesController < ApplicationController

  UPLOAD_NOTICE = "Your upload has been received and is now being processed. This may take some time depending on the size of the file. The status of your uploads can be seen in the table below. Click the 'Refresh Status' button to see an updated status."
  FORCE_SUBMIT_NOTICE = "Your request is now being processed. This may take some time depending on the size of the file. The status of your uploads can be seen in the table below. Click the 'Refresh Status' button to see an updated status."

  before_filter :authenticate_user!
  load_and_authorize_resource

  expose(:year_of_registration_range) { ConfigurationItem.year_of_registration_range }
  expose(:group_names_by_survey) { Question.group_names_by_survey }
  expose(:surveys) { SURVEYS.values }

  def new
  end

  def index
    set_tab :batches, :home
    @batch_files = @batch_files.order("created_at DESC").page(params[:page]).per_page(20)
  end

  def force_submit
    @batch_file.delay.process(:force)
    redirect_to batch_files_path, notice: FORCE_SUBMIT_NOTICE
  end

  def create
    @batch_file.user = current_user
    @batch_file.hospital = current_user.hospital
    if @batch_file.save
      supplementaries = params[:supplementary_files]
      if supplementaries
        supplementaries.each_pair { |key, supp_attrs| @batch_file.supplementary_files.create!(supp_attrs) if supp_attrs[:file] }
      end
      @batch_file.delay.process
      redirect_to batch_files_path, notice: UPLOAD_NOTICE
    else
      render :new
    end
  end

  def summary_report
    raise "No summary report for batch file" unless @batch_file.has_summary_report?
    send_file @batch_file.summary_report_path, :type => 'application/pdf', :disposition => 'attachment', :filename => "summary-report.pdf"
  end

  def detail_report
    raise "No detail report for batch file" unless @batch_file.has_detail_report?
    send_file @batch_file.detail_report_path, :type => 'text/csv', :disposition => 'attachment', :filename => "detail-report.csv"
  end
end
