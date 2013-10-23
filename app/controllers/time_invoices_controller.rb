class TimeInvoicesController < ApplicationController
  unloadable
  def index    
    project = Project.find(params[:project_id])
    return deny_access unless User.current.allowed_to?(:submit_invoiceable_time , project)
    
    @time_invoices = TimeInvoice.where(project_id: project.id)
  end
  
  def indexall
    time_invoices = TimeInvoice.includes(:project).all
    @time_invoices = time_invoices.delete_if {|ti| !User.current.allowed_to?(:submit_invoiceable_time , ti.project)}
  end
  
  def create
    @time_invoice = TimeInvoice.new(params[:time_invoice])
    if @time_invoice.save
      redirect_to time_invoices_path
    else
      render 'edit'
    end
  end
  
  def allowed_to_submit?(time_invoice)
    return false if time_invoice.submitted_by_id.present?
    return false unless User.current.allowed_to? :submit_invoiceable_time, @time_invoice.project
  end

  def edit
    @time_invoice = TimeInvoice.includes(:project).find(params[:id])
    
    return deny_access unless allowed_to_submit?(@time_invoice)
    
    @time_invoice.build_time_invoice_details
  end
  
  def update
    return deny_access unless allowed_to_submit?(@time_invoice)
    
    @time_invoice = TimeInvoice.find(params[:id])
    if @time_invoice.update_attributes(params[:time_invoice])
      redirect_to @time_invoice
    else
      render 'edit'
  end
  
  end
  def show  
    @time_invoice = TimeInvoice.find(params[:id])
    return deny_access unless User.current.allowed_to? :submit_invoiceable_time, @time_invoice.project
  end
end
