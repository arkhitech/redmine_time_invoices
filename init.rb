require 'redmine'
Mime::SET << Mime::PDF unless Mime::SET.include?(Mime::PDF)
Mime::SET << Mime::ATOM unless Mime::SET.include?(Mime::ATOM)
Rails.configuration.middleware.use "PDFKit::Middleware", {:print_media_type => true},:only => '/time_invoice_reports/report'
Rails.configuration.serve_static_assets = true
#The above three lines are setting Redmine level settings for the plug in

Rails.configuration.to_prepare do
  require_dependency 'user'
  User.send(:include, RedmineTimeInvoices::Patches::UserPatch)
  require_dependency 'project'
  Project.send(:include, RedmineTimeInvoices::Patches::ProjectPatch)
end

Redmine::Plugin.register :redmine_time_invoices do
  name 'Redmine Time Invoices'
  author 'Arkhitech'
  url 'http://github.com/arkhitech/redmine_time_invoices'
  author_url 'https://github.com/arkhitech'
  description 'Generates time invoice for each project where the Redmine Time Invoices plugin module is installed'
  version '0.0.1'
  
  project_module :time_invoices do
    permission :submit_invoiceable_time,:time_invoices => :index
    permission :generate_time_invoices,:time_invoices => [:index, :new]
    permission :edit_invoiceable_time, :time_invoices => :edit

    menu :project_menu, :time_invoices, 
      { controller: :time_invoices, :action => 'index' }, 
      after: :activity, param: :project_id
    
      Redmine::MenuManager.map :time_invoices_menu_project do |menu|
      menu.push :poverview,    { :controller => 'time_invoices', :action => 'index' },after: :activity, param: :project_id, :caption => 'Overview'
      menu.push :pgenerate_time_invoices, { :controller => 'time_invoices', :action=>'new' },after: :activity, param: :project_id, :caption => 'Generate Invoice'
      menu.push :preports,    { :controller => 'time_invoice_reports', :action => 'project_index' }, param: :project_id, :caption => 'Reports'
      menu.push :ptime_invoice_charts,      {:controller => 'time_invoice_charts', :action => 'index'}, :caption => 'Analytics'
    end 

    
    menu :top_menu, :time_invoices, 
      { controller: :time_invoices, action: 'indexall' },
      if: Proc.new {User.current.allowed_to_globally?(:submit_invoiceable_time,{}) ||
          User.current.allowed_to_globally?(:generate_time_invoices,{}) ||
          User.current.allowed_to_globally?(:edit_invoiceable_time,{})
    
      }
      
      Redmine::MenuManager.map :time_invoices_menu do |menu|
      menu.push :time_invoices,    { :controller => 'time_invoices', :action => 'indexall' }, :caption => 'Overview'
      menu.push :time_invoices_topnew, { :controller => 'time_invoices', :action=>'topnew' }, :caption => 'Generate Invoice'
      menu.push :time_invoice_reports,    { :controller => 'time_invoice_reports', :action => 'index' }, :caption => 'Reports'
      menu.push :time_invoice_charts,      {:controller => 'time_invoice_charts', :action => 'index'}, :caption => 'Analytics'
    end
     
      
    end
    
    
    
      
    settings default: {'group_mail' => [1]}, partial: 'settings/invoice_settings'
  end
