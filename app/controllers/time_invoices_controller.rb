class TimeInvoicesController < ApplicationController
  unloadable
    menu_item :time_invoices
    #menu_item :time_invoices_all, :only => :indexall
    #menu_item :time_invoices_top, :only => :topnew
    #menu_item :time_invoices_index, :only => :index
    #menu_item :time_invoices_new, :only => :new
    #menu_item :time_invoices
     
  before_filter :init_project
  if Redmine::Plugin.installed?(:redmine_contacts_invoices)
    include ContactsHelper
  end
  
  def init_project
    @project = params[:project_id] && Project.find(params[:project_id])
  end
  private :init_project
  
  def new
   
    return deny_access unless User.current.allowed_to?(:generate_time_invoices , @project)

    @time_invoice=TimeInvoice.new(:project_id => (@project && @project.id), 
      :start_date => (Date.today - 1.month).beginning_of_month, 
      :end_date => (Date.today-1.month).end_of_month)
  end
  
  def topnew
    return deny_access unless User.current.allowed_to_globally?(:submit_invoiceable_time ,{}) || 
      User.current.allowed_to_globally?(:generate_time_invoices , {}) ||
      User.current.allowed_to_globally?(:edit_invoiceable_time,{})
    @projects=projects_all
    return deny_access if @projects.empty?
    @time_invoice=TimeInvoice.new(:start_date => (Date.today-1.month).beginning_of_month,
      :end_date => (Date.today-1.month).end_of_month)
  end

  def index
    return deny_access unless User.current.allowed_to?(:submit_invoiceable_time , @project) || 
      User.current.allowed_to?(:generate_time_invoices , @project)
    
    @time_invoices = TimeInvoice.where(project_id: @project.id)
  end
  
  def indexall     
    return deny_access unless User.current.allowed_to_globally?(:submit_invoiceable_time ,{}) || 
      User.current.allowed_to_globally?(:generate_time_invoices , {}) ||
      User.current.allowed_to_globally?(:edit_invoiceable_time,{})
    time_invoices = TimeInvoice.includes(:project).all
    @time_invoices = time_invoices.delete_if {|ti| (!User.current.allowed_to?(:submit_invoiceable_time , ti.project) &&
          !User.current.allowed_to?(:generate_time_invoices , ti.project) &&
          !User.current.allowed_to?(:edit_invoiceable_time, ti.project)
      )}
  end
  
  def create
    @time_invoice = TimeInvoice.new(params[:time_invoice])
    if @time_invoice.save
      unless params[:project_id].nil?
        redirect_to :controller => 'time_invoices', :action=> 'index',
          :project_id=>params[:project_id]
      else
        redirect_to :indexall, :flash=>{:notice=> 'Time invoice has been successfully created!'}
      end
    else
      unless params[:project_id].blank?
        init_project
        render 'new'
      else
        @projects=projects_all
        return deny_access if @projects.empty?
        render 'topnew'
      end
    end
  end
  def allowed_to_submit?(time_invoice)
    return true if User.current.allowed_to? :edit_invoiceable_time, time_invoice.project
    return false if time_invoice.submitted_by_id.present?
    return false unless User.current.allowed_to? :submit_invoiceable_time, time_invoice.project
    return true
  end

  def edit
    @time_invoice = TimeInvoice.includes(:project).find(params[:id])
    return deny_access unless allowed_to_submit?(@time_invoice)
    
    unless @time_invoice.submitted_by_id.present?
      @time_invoice.build_time_invoice_details
    end
  end
  
  def update
       
    @time_invoice = TimeInvoice.find(params[:id])
    return deny_access unless allowed_to_submit?(@time_invoice)
    if @time_invoice.update_attributes(params[:time_invoice])
      if Setting.plugin_redmine_time_invoices['billing_invoice'] && Redmine::Plugin.installed?(:redmine_contacts_invoices)        
        unless @time_invoice.invoice_id.present?
          billing_invoice = Invoice.
            create!(number: "Invoice-#{Time.now.strftime("%Y%m%d%H%M%S")}",
            invoice_date: DateTime.now, project_id: @time_invoice.project_id, status_id: 1)
          billing_invoice.lines.build(quantity: @time_invoice.time_invoice_details.sum(:invoiced_quantity),
            description: "Billing Invoice")        
          billing_invoice.save!
          @time_invoice.invoice_id = billing_invoice.id
          @time_invoice.save!
        else
          billing_invoice = Invoice.find(@time_invoice.invoice_id)
          billing_invoice.lines.first.quantity = @time_invoice.time_invoice_details.sum(:invoiced_quantity)          
          billing_invoice.lines.first.save!
        end        
      end
      redirect_to :controller => 'time_invoices', :action=> 'show',:id=>@time_invoice.id,
        :project_id=>params[:project_id]
    else
      unless params[:project_id].nil?
        init_project
      end
      render 'edit'
    end
  
  end
  def show
    @time_invoice = TimeInvoice.find(params[:id])
    return deny_access unless User.current.allowed_to?(:submit_invoiceable_time , @time_invoice.project) || 
      User.current.allowed_to?(:generate_time_invoices , @time_invoice.project)
  end
  def projects_all
    projects=Project.all
    projects.delete_if {|project| !User.current.allowed_to?(:generate_time_invoices , project)}
  end
end
