class TimeInvoiceReportsController < ApplicationController
  unloadable

  before_filter :require_login
  include TimeInvoiceReportsHelper

  def index
    @all_users = User.all
    @groups= Group.all
  end
  
 
  def report
    @all_users = User.all
    @groups= Group.all
    #Making a model reference and assigning if to time_invoice_report variable | call initialize in model
    time_invoice_report = TimeInvoiceReport.new(params[:time_invoice_report])
    @time_invoice_details = time_invoice_report.generate
  end
end

