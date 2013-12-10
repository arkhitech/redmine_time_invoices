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
      pr=params[:time_invoice_report]
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
    
#-------------------------------------------------------------------------------     

      respond_to do |format|
        format.html { render :template => 'time_invoice_reports/report', :layout => !request.xhr? }
        format.api  {
          TimeInvoiceReport.load_visible_relations(@time_invoice_details) if include_in_api_response?('relations')
        }
        format.atom { render_feed(@time_invoice_details.time_invoice, :title => "#{@time_invoice_details || Setting.app_title}: 'Asim Feed'") }
        format.csv  { send_data(generate_csv(@time_invoice_details), :type => 'text/csv; header=present', :filename => 'time_invoice_report.csv') }
#        format.pdf  { send_data("ASIM", :type => 'application/pdf', :filename => 'time_invoice_report.pdf') }
     
      
      end

#-------------------------------------------------------------------------------
        

  
    end
  end
  
  def generate_csv(time_invoice_details)
    
#    row_data = [];

    FCSV.generate(:col_sep => ' ') do |csv|
      # csv header fields
      csv  << TimeInvoiceDetail.column_names
      # csv lines
      time_invoice_details.each do |time_invoice_detail|
#        
        csv << time_invoice_detail.attributes.values
#         row_data  << [time_invoice_detail.id,
#           time_invoice_detail.time_invoice_id,
#           time_invoice_detail.user_id,
#           time_invoice_detail.logged_hours,
#           time_invoice_detail.invoiced_hours,
#           time_invoice_detail.invoiced_quantity,
#           time_invoice_detail.invoiced_unit,
#           time_invoice_detail.comment,
#           time_invoice_detail.created_at,
#           time_invoice_detail.updated_at ]
#
#           end
#                 row_data.transpose do |row|
#                  csv << row
                  end
    end    
  end
  
  private :generate_csv
  
  def download
    @time_invoice_details=TimeInvoiceDetail.all
  end
  
  
end

