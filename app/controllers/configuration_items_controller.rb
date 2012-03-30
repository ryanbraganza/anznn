class ConfigurationItemsController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :year_of_registration, :admin_navigation

  def edit_year_of_registration
    load_values
  end

  def update_year_of_registration
    start_year = params[:start_year] || ""
    end_year = params[:end_year] || ""
    load_values
    @errors = validate_and_save(start_year, end_year)
    if @errors.empty?
      redirect_to(edit_year_of_registration_configuration_items_path, notice: "Year of registration range updated successfully.")
    else
      render :edit_year_of_registration
    end
  end

  private
  def validate_and_save(start_year, end_year)
    @start_year.configuration_value = start_year.strip
    @end_year.configuration_value = end_year.strip
    errors = []
    errors << "Start year is required" if @start_year.configuration_value.blank?
    errors << "End year is required" if @end_year.configuration_value.blank?
    errors << "Start year must be a number" unless (@start_year.configuration_value.blank? || @start_year.configuration_value =~ /\A(\d+)\Z/)
    errors << "End year must be a number" unless (@end_year.configuration_value.blank? || @end_year.configuration_value =~ /\A(\d+)\Z/)

    start_int = @start_year.configuration_value.to_i
    end_int = @end_year.configuration_value.to_i
    errors << "End year must be equal to or after start year" if (errors.empty? && (end_int < start_int))

    if errors.empty?
      @start_year.save!
      @end_year.save!
    end
    errors
  end

  def load_values
    @start_year = ConfigurationItem.find_by_name!(ConfigurationItem::YEAR_OF_REGISTRATION_START)
    @end_year = ConfigurationItem.find_by_name!(ConfigurationItem::YEAR_OF_REGISTRATION_END)
  end


end
