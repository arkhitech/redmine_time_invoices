task :generator => :environment do
  enabled_modules = EnabledModule.joins(:project).where(name: 'time_invoices', 
    "#{Project.table_name}.status" => Project::STATUS_ACTIVE)
  
  start_date = Date.today.beginning_of_month-1.month
  end_date = start_date.end_of_month

  roles=Role.all
  puts 'All Roles ever created in Redmine'
  puts roles
  selected_roles= roles.delete_if{|role| !role.has_permission?(:submit_invoiceable_time)}
  puts 'Roles which have the Permission to submit the invoiceable time'
 
  puts selected_roles
  memberss = selected_roles.collect {|selected_role| selected_role.members}
  #[[m1,m2,m3], [m1,m3,m5], [m5,m6,m1]]
  puts memberss
  members = memberss.flatten.uniq
  puts members
  #create a list of eligible members for each project
  project_members = {}
 members.each do |member| 
    project_members[member.project_id] ||= []
   project_members[member.project_id] << member
  end
   

  enabled_modules.each do |enabled_module|
    
    time_invoice = TimeInvoice.create!(
      project_id: enabled_module.project_id,
      start_date: start_date,
      end_date: end_date,      
    )
    
    members = project_members[enabled_module.project_id]
    
    unless members.nil?
      members.each {|member| TimeInvoiceMailer.
          time_invoice_notification_mail(member,time_invoice).deliver }
    else
      puts "Project: #{enabled_module.project.name} does not have any member with submit invoice permission"
    end
  end
end