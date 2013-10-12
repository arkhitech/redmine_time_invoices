Redmine::Plugin.register :redmine_time_invoices do
  name 'Redmine Time Invoices'
  author 'Arkhitech'
  description 'Generates time invoice for each project where the Redmine Time Invoices plugin module is installed'
  version '0.0.1'
   
  project_module :time_invoices do
    permission :submit_invoiceable_time,:time_invoices => :index
    menu :project_menu, :time_invoices, { :controller => 'time_invoices', :action => 'index' }, :caption => 'time_invoices', :after => :activity, :param => :project_id
    menu :top_menu, :time_invoices, { :controller => 'time_invoices', :action => 'indexall' }, :caption => 'time_invoices'  
  end
  settings default: {'mail' => 'info@arkhitech.com'}, partial: 'settings/invoice_settings'
end