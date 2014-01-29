class TimeInvoiceReportsController < ApplicationController
  unloadable

  before_filter :require_login
  before_filter :init_project_for_reports
  include TimeInvoiceReportsHelper
  
   def init_project_for_reports
    @project = params[:project_id] && Project.find(params[:project_id])
  end
  
  private :init_project_for_reports

  def index
    @all_users = User.active.sort_by{|e| e[:firstname]}
    @groups= Group.all.sort_by{|e| e[:firstname]}
    @show_options = true
  end
  
 def project_index
    @all_users = User.active.sort_by{|e| e[:firstname]}
    @groups= Group.all.sort_by{|e| e[:firstname]}
    @show_options = true
  end
 
  def report
    @all_users = User.active.sort_by{|e| e[:firstname]}
    @groups= Group.all.sort_by{|e| e[:firstname]}
    @show_options = true
    
    pr=params[:time_invoice_report]
    all_ok = true
    if pr.blank?
      flash[:error] = 'No Results For Empty Filters ----|----  
                         Please Choose Atleast One Report Generation Parameter!'
      all_ok = false
    elsif !pr[:invoiced_operator_value].blank? && !pr[:logged_operator_value].blank?
      #check for both errors
      if pr[:invoiced_time_compared_hours].blank? && pr[:logged_time_compared_hours].blank?
        flash[:error] = 'Please Enter Invoiced And Logged Hours To Fetch Results!'
         all_ok = false
      elsif pr[:invoiced_time_compared_hours].blank?
        flash[:error] = 'Please Enter Invoiced Hours  To Fetch Results'
         all_ok = false
      elsif pr[:logged_time_compared_hours].blank?          
        flash[:error] = 'Please Enter Logged Hours To Fetch Results!'
         all_ok = false
      end
    elsif !pr[:invoiced_operator_value].blank? && pr[:invoiced_time_compared_hours].blank?
      flash[:error] = 'Please Enter Invoiced Hours  To Fetch Results'
      all_ok = false      
    elsif !pr[:logged_operator_value].blank? && pr[:logged_time_compared_hours].blank?
      flash[:error] = 'Please Enter Logged Hours To Fetch Results!'
      all_ok = false
      
    #---------------------------------------------------------------------------
    
    elsif !pr[:invoiced_time_compared_hours].blank? && !pr[:logged_time_compared_hours].blank?
      #check for both errors
      if pr[:invoiced_operator_value].blank? && pr[:logged_operator_value].blank?
        flash[:error] = 'Please Enter Invoiced And Logged Operators To Fetch Results!'
         all_ok = false
      elsif pr[:invoiced_operator_value].blank?
        flash[:error] = 'Please Enter Invoiced Operator  To Fetch Results'
         all_ok = false
      elsif pr[:logged_operator_value].blank?          
        flash[:error] = 'Please Enter Logged Operator To Fetch Results!'
         all_ok = false
      end
    elsif pr[:invoiced_operator_value].blank? && !pr[:invoiced_time_compared_hours].blank?
      flash[:error] = 'Please Enter Invoiced Operator   To Fetch Results'
      all_ok = false      
    elsif pr[:logged_operator_value].blank? && !pr[:logged_time_compared_hours].blank?
      flash[:error] = 'Please Enter Logged Operator To Fetch Results!'
      all_ok = false    
    elsif (pr[:start_date_from].blank? &&
          pr[:start_date_to].blank? &&
          pr[:end_date_from].blank? &&
          pr[:end_date_to].blank? &&
          pr[:selected_users].blank? &&
          pr[:groups].blank? &&
          pr[:submitted_by_user].blank? &&
          (pr[:invoiced_time_compared_hours].blank? ||
            pr[:invoiced_operator_value].blank?) &&
          (pr[:logged_time_compared_hours].blank? ||
            pr[:logged_operator_value].blank?) &&
          pr[:projects].blank?)                 
      flash[:error] = 'No Results For Empty Filters ----|----  
                         Please Choose Atleast One Report Generation Parameter!'
      all_ok = false    
    end
  
    #---------------------------------------------------------------------------
    
    if !all_ok
      respond_to do |format|
        format.html {redirect_to action: :index}
        format.json { render json: "No result founds", :status => :unprocessable_entity }
        format.all {render :nothing => true, :status => :unprocessable_entity}
        
      end
      return
    end
    
    #else all is good
      
     #1
     #render retains values but if refreshed with URL : gives error
     #redirect_to resets values but does not give error on refresh
     
      time_invoice_report = TimeInvoiceReport.new(params[:time_invoice_report])
      
      if !time_invoice_report.valid?
        flash[:error] = time_invoice_report.errors.full_messages.join("\n")
        #redirect_to action: :index
        respond_to do |format|
          format.html {render 'index'}
          format.json { render json: time_invoice_report.errors, :status => :unprocessable_entity }
          format.all {render :nothing => true, :status => :unprocessable_entity}
        end
      else
        
      @time_invoice_details = time_invoice_report.generate
    
      #Display view if data is available
      flash[:error] = 'No Results Found!' if @time_invoice_details.blank?
      
#-------------------------------------------------------------------------------     
      respond_to do |format|
        format.html { 
          @show_options = false if request.env["Rack-Middleware-PDFKit"] == "true"            
          
          render :template => 'time_invoice_reports/report',
          :layout => !request.xhr? }
        format.api  {
          TimeInvoiceReport.load_visible_relations
          (@time_invoice_details) if include_in_api_response?('relations')
        }
        
        format.atom { render_ti_feed(@time_invoice_details, 
            :title => "Time Invoices Report in ATOM Feed") }
        #this could be made as TimeInvoiceDetail.all.first.attributes.to_xml
        
        format.rss { render :layout => false }
        format.csv  { send_data(generate_csv(@time_invoice_details),
            :type => 'text/csv; header=present', :filename => 'time_invoice_report.csv') }
      end
      #------------------------------------------------------------------------------- 
    end
#   end
  end
  
  
  #----------------------------------------------------------------------------
    def project_report
    @all_users = User.active.sort_by{|e| e[:firstname]}
    @groups= Group.all.sort_by{|e| e[:firstname]}
    @show_options = true
    
    params[:time_invoice_report][:projects]= Project.where(:identifier=>params[:project_id]).pluck(:id)
    
    puts "project value ^^^^^^^^^^^^^^^^^^^^^^^ #{params[:time_invoice_report][:projects]} "
    puts "Project Params ^^^^^^^^^^^^^^^^^^^^^^^ #{params[:time_invoice_report]} "
    
    pr=params[:time_invoice_report]
    all_ok = true
    if pr.blank?
      flash[:error] = 'No Results For Empty Filters ----|----  
                         Please Choose Atleast One Report Generation Parameter!'
      all_ok = false
    elsif !pr[:invoiced_operator_value].blank? && !pr[:logged_operator_value].blank?
      #check for both errors
      if pr[:invoiced_time_compared_hours].blank? && pr[:logged_time_compared_hours].blank?
        flash[:error] = 'Please Enter Invoiced And Logged Hours To Fetch Results!'
         all_ok = false
      elsif pr[:invoiced_time_compared_hours].blank?
        flash[:error] = 'Please Enter Invoiced Hours  To Fetch Results'
         all_ok = false
      elsif pr[:logged_time_compared_hours].blank?          
        flash[:error] = 'Please Enter Logged Hours To Fetch Results!'
         all_ok = false
      end
    elsif !pr[:invoiced_operator_value].blank? && pr[:invoiced_time_compared_hours].blank?
      flash[:error] = 'Please Enter Invoiced Hours  To Fetch Results'
      all_ok = false      
    elsif !pr[:logged_operator_value].blank? && pr[:logged_time_compared_hours].blank?
      flash[:error] = 'Please Enter Logged Hours To Fetch Results!'
      all_ok = false
      
    #---------------------------------------------------------------------------
    
    elsif !pr[:invoiced_time_compared_hours].blank? && !pr[:logged_time_compared_hours].blank?
      #check for both errors
      if pr[:invoiced_operator_value].blank? && pr[:logged_operator_value].blank?
        flash[:error] = 'Please Enter Invoiced And Logged Operators To Fetch Results!'
         all_ok = false
      elsif pr[:invoiced_operator_value].blank?
        flash[:error] = 'Please Enter Invoiced Operator  To Fetch Results'
         all_ok = false
      elsif pr[:logged_operator_value].blank?          
        flash[:error] = 'Please Enter Logged Operator To Fetch Results!'
         all_ok = false
      end
    elsif pr[:invoiced_operator_value].blank? && !pr[:invoiced_time_compared_hours].blank?
      flash[:error] = 'Please Enter Invoiced Operator   To Fetch Results'
      all_ok = false      
    elsif pr[:logged_operator_value].blank? && !pr[:logged_time_compared_hours].blank?
      flash[:error] = 'Please Enter Logged Operator To Fetch Results!'
      all_ok = false    
    elsif (pr[:start_date_from].blank? &&
          pr[:start_date_to].blank? &&
          pr[:end_date_from].blank? &&
          pr[:end_date_to].blank? &&
          pr[:selected_users].blank? &&
          pr[:groups].blank? &&
          pr[:submitted_by_user].blank? &&
          (pr[:invoiced_time_compared_hours].blank? ||
            pr[:invoiced_operator_value].blank?) &&
          (pr[:logged_time_compared_hours].blank? ||
            pr[:logged_operator_value].blank?) &&
          pr[:projects].blank?)                 
      flash[:error] = 'No Results For Empty Filters ----|----  
                         Please Choose Atleast One Report Generation Parameter!'
      all_ok = false    
    end
  
    #---------------------------------------------------------------------------
    
    if !all_ok
      respond_to do |format|
        format.html {redirect_to action: :project_index}
        format.json { render json: "No result founds", :status => :unprocessable_entity }
        format.all {render :nothing => true, :status => :unprocessable_entity}
        
      end
      return
    end
    
    #else all is good
      
     #1
     #render retains values but if refreshed with URL : gives error
     #redirect_to resets values but does not give error on refresh
     
      time_invoice_report = TimeInvoiceReport.new(params[:time_invoice_report])
      
      if !time_invoice_report.valid?
        flash[:error] = time_invoice_report.errors.full_messages.join("\n")
        #redirect_to action: :index
        respond_to do |format|
          format.html {render 'project_index'}
          format.json { render json: time_invoice_report.errors, :status => :unprocessable_entity }
          format.all {render :nothing => true, :status => :unprocessable_entity}
        end
      else
        
      @time_invoice_details = time_invoice_report.generate
    
      #Display view if data is available
      flash[:error] = 'No Results Found!' if @time_invoice_details.blank?
      
#-------------------------------------------------------------------------------     
      respond_to do |format|
        format.html { 
          @show_options = false if request.env["Rack-Middleware-PDFKit"] == "true"            
          
          render :template => 'time_invoice_reports/project_report',
          :layout => !request.xhr? }
        format.api  {
          TimeInvoiceReport.load_visible_relations
          (@time_invoice_details) if include_in_api_response?('relations')
        }
        
        format.atom { render_ti_feed(@time_invoice_details, 
            :title => "Time Invoices Report in ATOM Feed") }
        #this could be made as TimeInvoiceDetail.all.first.attributes.to_xml
        
        format.rss { render :layout => false }
        format.csv  { send_data(generate_csv(@time_invoice_details),
            :type => 'text/csv; header=present', :filename => 'time_invoice_project_report.csv') }
      end
      #------------------------------------------------------------------------------- 
    end
#   end
  end #END OF PROJECT REPORT
  
  
  def render_ti_feed(items, options={})
    
    items.each do |time_invoice_detail|
      @items = time_invoice_detail.attributes.values || []
    end
    
    @items = @items.slice(0, Setting.feeds_limit.to_i)
    @title = options[:title] || Setting.app_title
    render :template => "time_invoice_reports/feed", :formats => [:atom], :layout => false,
      :content_type => 'application/atom+xml'
  end
  
  
  def generate_csv(time_invoice_details)
    
    
    FCSV.generate(:col_sep => ',') do |csv|
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



