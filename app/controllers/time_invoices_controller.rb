class TimeInvoicesController < ApplicationController
  unloadable


 def index
  @project = Project.find(params[:project_id])
  
    @time_invoices=Timeinvoices.find(:all)
  end
  
 #private
  #def find_project
    
  #end
end
