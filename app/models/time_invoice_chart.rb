class TimeInvoiceChart
  include ActiveModel::Validations
  
  unloadable
  attr_accessor :chart_options
  validates :date_from, :allow_blank => true, :format => {:with => /\A\d{4}-\d{2}-\d{2}( 00:00:00)?\z/}
  validates :date_to, :allow_blank => true, :format => {:with => /\A\d{4}-\d{2}-\d{2}( 00:00:00)?\z/}
  validate  :validate_date_pairs
  
  attr_accessor :date_from, :date_to
  
  def initialize(options) 
    puts "#{'*'*1000}Options #{options}"
    @chart_options = options
    self.date_from = options[:date_from]
    self.date_to = options[:date_to]
  end
  
  def validate_date_pairs
    if @chart_options[:date_from] > @chart_options[:date_to] && !chart_options[:date_to].blank?
      errors.add(:start_date, 'From Date Cannot Be smaller than To Date') 
    end
    nil
  end
  
  
  def get_unique_all_or_group_users
    
    selected_group = @chart_options[:group]
    puts "#{'*'*1000}This is selected group #{selected_group}"
    if !selected_group.nil? || !selected_group.blank?
      
      selected_group_users = User.active.joins(:groups).
        where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" =>
          selected_group)
          

#      puts "These are Redmine selected group users #{selected_group_users}"

      selected_users=[]
      selected_group_users.each do |group_user|
        selected_users << User.find(group_user).id.to_s
      end
      
#      selected_users=selected_group_users
      
      selected_users = selected_users.uniq
      
      unless selected_users.nil?
        #        @time_invoice_details = @time_invoice_details.where(:user_id => selected_users)
        puts "#{'+'*80}\nSelcted Users of Group #{selected_users}\n#{'*'*80}"
      end
    else
      selected_users= User.pluck(:id) #CHECK
      puts "#{'+'*80}\nAll Users #{selected_users}\n#{'*'*80}"
      #      @time_invoice_details = @time_invoice_details.where(:user_id => selected_users)
    end
    selected_users
  end
  
  def generate
    @time_invoice_details=TimeInvoiceDetail.includes(:time_invoice)
    
    #Group=========================================================================

    selected_users=get_unique_all_or_group_users
    puts "#{'+'*80}\nSelcted Users Count #{selected_users.count}"
    @time_invoice_details = @time_invoice_details.where(:user_id => selected_users)

    #===============================================================================

    #Start Date=====================================================================
    
    unless @chart_options[:date_from].blank?
      @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.start_date >= ?", 
        @chart_options[:date_from])
    else
      @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.start_date >= ?", 
        Date.today-1.year)
    end
    
    unless @chart_options[:date_to].blank?
      @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.end_date <= ?", 
        @chart_options[:date_to])
    else
      @time_invoice_details = @time_invoice_details.where("#{TimeInvoice.table_name}.start_date >= ?", 
        Date.today)
    end
    
    
      
    puts "#{'*'*80}\nTime invoice Start Time #{@time_invoice_details.count(:all)}\n#{'*'*80}"


    #===============================================================================
    @time_invoice_details
  
  end
  
  
  def generate_individual
    @time_invoice_details_individual=TimeInvoiceDetail.includes(:time_invoice)

    #User===========================================================================
    selected_user = @chart_options[:selected_user]
    if selected_user.present?
      @time_invoice_details_individual =@time_invoice_details_individual.where(:user_id => selected_user)
    else
      @time_invoice_details_individual =@time_invoice_details_individual.where(:user_id => User.current.id)
    end
    puts "#{'-'*80}\nSelcted User Without Group #{selected_user}\n#{'*'*80}"

    #===========================================================================
    
    #Start Date=====================================================================
    
    unless @chart_options[:date_from].blank?
      @time_invoice_details_individual =@time_invoice_details_individual.where("#{TimeInvoice.table_name}.start_date >= ?", 
        @chart_options[:date_from])
    else
      @time_invoice_details_individual =@time_invoice_details_individual.where("#{TimeInvoice.table_name}.start_date >= ?", 
        Date.today-1.year)
    end
    
    unless @chart_options[:date_to].blank?
      @time_invoice_details_individual =@time_invoice_details_individual.where("#{TimeInvoice.table_name}.end_date <= ?", 
        @chart_options[:date_to])
    else
      @time_invoice_details_individual =@time_invoice_details_individual.where("#{TimeInvoice.table_name}.start_date >= ?", 
        Date.today)
    end
    
    
      
    puts "#{'*'*80}\nTime invoice Start Time #{@time_invoice_details.count(:all)}\n#{'*'*80}"


    #===============================================================================
    @time_invoice_details_individual
    
    
    
  end
  
  
  def find_working_days
    
    if !@chart_options[:date_from].blank? && !@chart_options[:date_to].blank?
#      @working_days=(Date::civil(@chart_options[:date_from])..Date::civil(@chart_options[:date_to])).count {|date| date.wday >= 1 && date.wday <= 5}
      @working_days= (@chart_options[:date_from].to_date..@chart_options[:date_to].to_date).count {|date| date.wday >= 1 && date.wday <= 5}
      puts "Working Days From+To=true ================================== #{@working_days}"
       
    elsif !@chart_options[:date_from].blank? && @chart_options[:date_to].blank?
      @working_days=(@chart_options[:date_from].to_date..(@chart_options[:date_from].to_date)+1.year).count {|date| date.wday >= 1 && date.wday <= 5}
      puts "working days From=true ================================== #{@working_days}"
      elseif @chart_options[:date_from].blank? && !@chart_options[:date_to].blank?
      @working_days=((@chart_options[:date_from].to_date)-1.year..@chart_options[:date_from].to_date).count {|date| date.wday >= 1 && date.wday <= 5}
      puts "working days To=true================================== #{@working_days}"
    else
      @working_days=((Date.today-1.year)..Date.today).count {|date| date.wday >= 1 && date.wday <= 5}
      puts "working days From+To=false ================================== #{@working_days}"
    end
    
    @working_days
    
  end
  
  def find_all_group_leaves(start_date,end_date)
    selected_group = @chart_options[:group]
    if selected_group.nil? || selected_group.blank?
      total_leave_count= UserLeave.where(leave_date: start_date..end_date).count
    else
      selected_group_users=get_unique_all_or_group_users
#      total_leave_count=UserLeave.where(user_id:  selected_group_users,leave_date: start_date..end_date).sum(:fractional_leave)
      total_leave_count=UserLeave.where(user_id:  selected_group_users,leave_date: start_date..end_date).count
    end
    puts "Total Leaves ================================== #{total_leave_count}"
    total_leave_count
  end
  
  def find_individual_leaves(start_date,end_date,user)
    individual_leave_count=UserLeave.where(user_id: user, leave_date: start_date..end_date).count
    puts "Total Leaves Individual ================================== #{individual_leave_count}"
    individual_leave_count
     
  end
  
end
