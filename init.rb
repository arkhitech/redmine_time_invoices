Redmine::Plugin.register :invoice_generator do
  name 'Invoice Generator plugin'
  author 'Saba'
  description 'This is a plugin for Redmine'
  version '0.0.1'
   
  project_module :time_invoices do
    permission :view_time_invoices, :time_invoices => :index
menu :project_menu, :time_invoices, { :controller => 'time_invoices', :action => 'index' }, :caption => 'time_invoices', :after => :activity, :param => :project_id
end
end