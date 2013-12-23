class TimeInvoicesController < ApplicationController
  unloadable
  before_filter :init_project

  include ContactsHelper
  
  def init_project
    @project = params[:project_id] && Project.find(params[:project_id])
  end
  private :init_project
  
  def new
   
    return deny_access unless User.current.allowed_to?(:generate_time_invoices , @project)

    @time_invoice=TimeInvoice.new(:project_id => (@project && @project.id))
  end
  
  def topnew
    return deny_access unless User.current.allowed_to_globally?(:submit_invoiceable_time ,{}) || 
      User.current.allowed_to_globally?(:generate_time_invoices , {})
    @projects=Project.all
    @projects = @projects.delete_if {|project| !User.current.allowed_to?(:generate_time_invoices , project)}
    @time_invoice=TimeInvoice.new
  end

  def index
    #@project_id=params[:project_id]
    #project = Project.find(params[:project_id])
    return deny_access unless User.current.allowed_to?(:submit_invoiceable_time , @project) || 
      User.current.allowed_to?(:generate_time_invoices , @project)
    
    @time_invoices = TimeInvoice.where(project_id: @project.id)
  end
  
  def indexall     
    return deny_access unless User.current.allowed_to_globally?(:submit_invoiceable_time ,{}) || 
      User.current.allowed_to_globally?(:generate_time_invoices , {})
    time_invoices = TimeInvoice.includes(:project).all
    @time_invoices = time_invoices.delete_if {|ti| !User.current.allowed_to?(:submit_invoiceable_time , ti.project)}
  end
  
  def create
    @time_invoice = TimeInvoice.new(params[:time_invoice])
    if @time_invoice.save      
      redirect_to @time_invoice
    else
      unless params[:project_id].nil?
        render 'new'
      else
        render 'topnew'
      end
    end
  end
  def allowed_to_submit?(time_invoice)
    return false if time_invoice.submitted_by_id.present?
    return false unless User.current.allowed_to? :submit_invoiceable_time, @time_invoice.project
    return true
  end

  def edit
    @time_invoice = TimeInvoice.includes(:project).find(params[:id])
    return deny_access unless allowed_to_submit?(@time_invoice)
    
    @time_invoice.build_time_invoice_details
  end
  
  def update
       
    @time_invoice = TimeInvoice.find(params[:id])
    return deny_access unless allowed_to_submit?(@time_invoice)
    if @time_invoice.update_attributes(params[:time_invoice])
      if Setting.plugin_redmine_time_invoices['billing_invoice'] && Redmine::Plugin.installed?(:redmine_contacts_invoices)        
        billing_invoice = Invoice.
          create!(number: "Billing Invoice for #{Project.find(@time_invoice.project_id).name}",
          invoice_date: DateTime.now, project_id: @time_invoice.project_id, status_id: 1)
        billing_invoice.lines.build(invoice_id: billing_invoice.id, 
          quantity: @time_invoice.time_invoice_details.sum(:invoiced_quantity), description: "Billing Invoice")        
        billing_invoice.save!
      end
      redirect_to @time_invoice
    else
      render 'edit'
    end
  
  end
  def show  
    @time_invoice = TimeInvoice.find(params[:id])
    return deny_access unless User.current.allowed_to?(:submit_invoiceable_time , @time_invoice.project) || 
      User.current.allowed_to?(:generate_time_invoices , @time_invoice.project)
  end
end
