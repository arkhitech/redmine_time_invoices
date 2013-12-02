class TimeInvoiceReportsController < ApplicationController
  unloadable


  def index
     @all_users = User.all
     @groups= Group.all
  end
  
  def test
    
  end

  def show
    
  end
  def report
    
    @time_invoice_reports = TimeInvoice
    
    unless params[:user_leave_report][:selected_users].nil?
      #where_statements << 'user_id IN (?)'
      #where_clause << params[:user_leave_report][:selected_users]
      @time_invoice_reports.where(:user_id => params[:user_leave_report][:selected_users])
    end

    selected_leave_types = params[:user_leave_report][:selected_leave_types]
    unless selected_leave_types.nil?
      #where_statements << 'leave_type IN (?)'
      #where_clause << selected_leave_types
      @time_invoice_reports.where(:leave_type => selected_leave_types)
    end

    unless params[:user_leave_report][:date_from].blank? 
#      where_statements << 'leave_date >= ?'
#      where_clause << params[:user_leave_report][:date_from]
      @time_invoice_reports.where('leave_date >= ?', params[:user_leave_report][:date_from])
    end

    unless params[:user_leave_report][:date_to].blank?
#      where_statements << 'leave_date <= ?'
#      where_clause << params[:user_leave_report][:date_to]
      @time_invoice_reports.where('leave_date <= ?', params[:user_leave_report][:date_to])
    end

    #where_clause[0] = where_statements.join(' AND ') 
    #@time_invoice_reports = UserLeave.where(where_clause).order('leave_date desc')
    @time_invoice_reports = @time_invoice_reports.order('leave_date desc')
  
  end

  end

