class TimeInvoiceReportsController < ApplicationController
  unloadable

  before_filter :require_login
  include TimeInvoiceReportsHelper

  def index
    @all_users = User.all
    @groups= Group.all
  end
  
    def download
    @time_invoice_details=TimeInvoiceDetail.all
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
      @updated = @time_invoice_details.first.updated_at unless @time_invoice_details.empty?

      
      
      
      
      respond_to do |format|
        format.html { render :template => 'time_invoice_reports/report', :layout => !request.xhr? }
        format.api  {
          TimeInvoiceReport.load_visible_relations(@time_invoice_details) if include_in_api_response?('relations')
        }
        
        format.atom { render_ti_feed(@time_invoice_details, :title => "Time Invoices Report in ATOM Feed") }
        format.rss { render :layout => false }
#        format.atom { render :layout => false }
#         # we want the RSS feed to redirect permanently to the ATOM feed
#        format.rss { redirect_to feed_path(:format => :atom), :status => :moved_permanently }

        format.csv  { send_data(generate_csv(@time_invoice_details), :type => 'text/csv; header=present', :filename => 'time_invoice_report.csv') }
#        format.pdf  { send_data("ASIM", :type => 'application/pdf', :filename => 'time_invoice_report.pdf') }  
      end
#------------------------------------------------------------------------------- 
    end
  end
  
  def render_ti_feed(items, options={})
    items.each do |time_invoice_detail|
    @items = time_invoice_detail.attributes.values || []
    end
    
#    @items.sort! {|x,y| y.event_datetime <=> x.event_datetime }
    @items = @items.slice(0, Setting.feeds_limit.to_i)
    @title = options[:title] || Setting.app_title
    render :template => "time_invoice_reports/feed", :formats => [:atom], :layout => false,
           :content_type => 'application/atom+xml'
  end
  
  
  def generate_csv(time_invoice_details)
    
    
    FCSV.generate(:col_sep => ' ') do |csv|
      # csv header fields
      csv  << TimeInvoiceDetail.column_names
      
      # csv lines
      time_invoice_details.each do |time_invoice_detail|
        
        csv << time_invoice_detail.attributes.values
        
      end
    end    
  end
  
  private :generate_csv
    private :render_ti_feed

  
  
end

