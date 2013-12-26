namespace :redmine_time_invoices do
  task :generate_invoices => :environment do
    logger = Rails.logger
    logger.info 'Generating Time Invoices'
    
    enabled_modules = EnabledModule.joins(:project).where(name: 'time_invoices', 
      "#{Project.table_name}.status" => Project::STATUS_ACTIVE)
  
    start_date = Date.today.beginning_of_month#-1.month
    end_date = start_date.end_of_month
   
    enabled_modules.each do |enabled_module|
    
      time_invoice = TimeInvoice.create!(
        project_id: enabled_module.project_id,
        start_date: start_date,
        end_date: end_date,      
      )
    end
  end
end