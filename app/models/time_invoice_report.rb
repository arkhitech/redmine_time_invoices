class TimeInvoiceReport
  unloadable
  attr_accessor :report_options
  
  def initialize(options) 
    @report_options = options
  end
  
  def generate
    #@time_invoices = TimeInvoice
    @time_invoice_details=TimeInvoiceDetail.includes(:time_invoice)
    #@time_invoice_details=TimeInvoiceDetail.joins(:time_invoice)
 
#Start Date=====================================================================
    
    if @report_options[:start_date_from] > @report_options[:start_date_to]
      #      redirect_to time_invoice_reports_index_path
      flash[:error] = 'For Start Date :From Date cannot be smaller than To Date ' 
    else
      unless @report_options[:start_date_from].blank?
        @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.start_date >= ?", 
          @report_options[:start_date_from])
      end
      unless @report_options[:start_date_to].blank?
        @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.start_date <= ?", 
          @report_options[:start_date_to])
      end 
      
      puts "#{'*'*80}\nTime invoice Start Time #{@time_invoice_details.count(:all)}\n#{'*'*80}"
    end

#===============================================================================

#End Date=======================================================================    
     
    if  @report_options[:end_date_from] > @report_options[:end_date_to]
      #      redirect_to time_invoice_reports_index_path
      flash.now[:error] = 'For End Date :From Cannot be smaller than To Date '
    else
      unless @report_options[:end_date_from].blank?
        @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.end_date >= ?", 
          @report_options[:end_date_from])
      end
      unless @report_options[:end_date_to].blank?
        @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.end_date <= ?", 
          @report_options[:end_date_to])
      end  
      puts "#{'*'*80}\nTime invoice End Time #{@time_invoice_details.count(:all)}\n#{'*'*80}"
    end   
    
   
#===============================================================================    

    
#User===========================================================================
    selected_users = @report_options[:selected_users]
    if selected_users.present?
      @time_invoice_details = @time_invoice_details.where(:user_id => selected_users)
    end
    puts "#{'-'*80}\nSeelcted Users Without Group #{selected_users}\n#{'*'*80}"

#===============================================================================

    
#Group==========================================================================
selected_groups = @report_options[:groups]
    puts "#{'*'*1000}These are selected groups #{selected_groups}"
    unless selected_groups.nil?
      
            selected_group_users = User.active.joins(:groups).
              where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" =>
                selected_groups)
      
      if selected_users.nil?
        selected_users=[]
      end
#      selected_groups_users=[]
#      selected_groups.each do |sg|
#        selected_groups_users<<sg.users
#      end
#      selected_groups_users.flatten!
      puts "These are Redmine selected users #{selected_group_users}"

      
      selected_group_users.each do |group_user|
        selected_users << User.find(group_user).id.to_s
      end
      
      selected_users = selected_users.uniq
      
      unless selected_users.nil?
        @time_invoice_details = @time_invoice_details.where(:user_id => selected_users)
        puts "#{'+'*80}\nSeelcted Users #{selected_users}\n#{'*'*80}"
      end
    end
    
    
    
    
#===============================================================================

#Submitted By User==============================================================  
    unless @report_options[:submitted_by_user].blank?
      @time_invoice_details = @time_invoice_details.
        where("#{TimeInvoice.table_name}.submitted_by_id" =>
          @report_options[:submitted_by_user])
      puts "#{'SBU-'*80}\nTime Invoice Submitted by User 
                                {@time_invoice_details.count(:all)}\n#{'*'*80}#"
    end
    
    
#===============================================================================
    
        
#Invoiced Time==================================================================
        
    unless @report_options[:invoiced_time_compared_hours].blank?
          
      puts "#{'%'*80}\nInside Time Invoice Report 
                    {@report_options[:invoiced_time_compared_hours]}\n#{'*'*80}#"
          
      invoiced_operator_value=@report_options[:invoiced_operator_value]
          
      if invoiced_operator_value =='<'
        sum_invoiced_time_users = @time_invoice_details.dup
        sum_invoiced_time_users = sum_invoiced_time_users.group(:user_id).
          having('SUM(invoiced_hours) < ?', @report_options[:invoiced_time_compared_hours].to_i)

        @time_invoice_details = @time_invoice_details.
          where(user_id: sum_invoiced_time_users.collect{|it| it.user_id})          
        puts "#{'I'*80}\nInside Less than Invoice Condition "
      end
          
      if invoiced_operator_value =='>'
        sum_invoiced_time_users = @time_invoice_details.dup
        sum_invoiced_time_users = sum_invoiced_time_users.group(:user_id).
          having('SUM(invoiced_hours) > ?', @report_options[:invoiced_time_compared_hours].to_i)
            
        @time_invoice_details = @time_invoice_details.where(user_id: sum_invoiced_time_users.collect{|it| it.user_id})          
        puts "#{'I'*80}\nInside Greater  than Invoice Condition "
              
      end
      
    end
#===============================================================================
     
#Logged Time===================================================================
        
    unless @report_options[:logged_time_compared_hours].blank?          
      puts "#{'%'*80}\nInside Time Invoice Report 
                    {@report_options[:logged_time_compared_hours]}\n#{'*'*80}#"          
      logged_operator_value=@report_options[:logged_operator_value]
          
      if logged_operator_value =='<'
        sum_logged_time_users = @time_invoice_details.dup
        sum_logged_time_users = sum_logged_time_users.group(:user_id).
          having('SUM(logged_hours) < ?', @report_options[:logged_time_compared_hours].to_i)
        puts "Got logged_time_users: #{sum_logged_time_users.inspect}"
        @time_invoice_details = @time_invoice_details.
          where(user_id: sum_logged_time_users.collect{|it| it.user_id})          
        puts "#{'L1'*80}\nInside Less than Logged Condition "
      end
          
      if logged_operator_value =='>'
        sum_logged_time_users = @time_invoice_details.dup
        sum_logged_time_users = sum_logged_time_users.group(:user_id).
          having('SUM(logged_hours) > ?', @report_options[:logged_time_compared_hours].to_i)
            
        @time_invoice_details = @time_invoice_details.where(user_id: sum_logged_time_users.collect{|it| it.user_id})          
        puts "#{'L2'*80}\nInside Greater  than Logged Condition "
              
      end
      
    end  
    #
 
#===============================================================================

    puts "#{'F'*80}\nTime invoice End Time #{@time_invoice_details.count(:all)}\n#{'*'*80}"
    @time_invoice_details
  end
  
   
  
end
