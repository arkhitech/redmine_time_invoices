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

    menu :project_menu, :time_invoices, 
      { controller: :time_invoices, :action => 'index' }, 
      after: :activity, param: :project_id

    
      menu :top_menu, :time_invoices, 
        { controller: :time_invoices, action: 'indexall' } 

      end
      
      settings default: {'group_mail' => [1]}, partial: 'settings/invoice_settings'
    end
