class TimeInvoiceReportsController < ApplicationController
  unloadable

  before_filter :require_login
  include TimeInvoiceReportsHelper

  def index
    @all_users = User.all
    @groups= Group.all
  end
  
 
  def report
    @all_users = User.all
    @groups= Group.all
 
    #Making a model reference and assigning if to time_invoice_report variable | call initialize in model
      pr=params[:time_invoice_report];
    if pr[:start_date_from].blank? &&
       pr[:start_date_to].blank? &&
       pr[:end_date_from].blank? &&
       pr[:end_date_to].blank? &&
       pr[:selected_users].blank? &&
       pr[:groups].blank? &&
       pr[:submitted_by_user].blank? &&
       pr[:invoiced_time_compared_hours].blank? &&
       pr[:invoiced_operator_value].blank? &&
       pr[:logged_operator_value].blank? &&
       pr[:logged_time_compared_hours].blank? 
     
      #OR if pr[:all].blank?
        
      flash[:error] = 'Please Choose A Report Generation Parameter!' 
    else
    time_invoice_report = TimeInvoiceReport.new(params[:time_invoice_report])
    @time_invoice_details = time_invoice_report.generate
    end
  end
end

