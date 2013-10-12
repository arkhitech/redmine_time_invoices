class TimeInvoicesController < ApplicationController
  unloadable
<<<<<<< HEAD
  def index
    @project=Project.find(params[:project_id])
    p=Project.where(identifier: params[:project_id])
    
    @time_invoices=TimeInvoice.where(project_id: p[0].id)
  end
  
  def indexall
    @time_invoices=TimeInvoice.all
    
  end
  
  def create
    
    @timeinvoice=TimeInvoice.new(params[:time_invoice])
    if @timeinvoice.save
      redirect_to time_invoices_path
    end
  end
  
  def edit
    @time_invoice = TimeInvoice.find(params[:id])
    @time_invoice.build_time_invoice_details
    
  end
  
  def update
    @time_invoice = TimeInvoice.find(params[:id])
    if @time_invoice.update_attributes(params[:time_invoice])
      redirect_to @time_invoice
    else
      render 'edit'
  end
  end
  def show  
    @time_invoice=TimeInvoice.find(params[:id])
  end
end
=======


 def index
  @project = Project.find(params[:project_id])
  
    @time_invoices=Timeinvoices.find(:all)
  end
  
 #private
  #def find_project
    
  #end
end
>>>>>>> 7b8cb405674ed3941ef7151d0dc7b29f823cba97
