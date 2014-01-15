class TimeInvoiceMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end
  
  def notify_time_invoice_generated(time_invoice)
    users=[]
    #self.project.users
    members = time_invoice.project.users
    members.each do |member|
      if User.exists?(member.id)
        users << User.find(member.id)
      else
        users << Group.find(member.id).users
      end
    end
    users = users.flatten.uniq
    users.delete_if{|user| !user.allowed_to?(:submit_invoiceable_time,time_invoice.project)}
    unless users.nil?
      users.each do |user|
        @user=user
        @time_invoice=time_invoice
        mail(to: @user.mail, subject: "Time Invoice Created for Project: #{@time_invoice.project}" )
      end
    else
      logger.debug "Project: #{enabled_module.project.name} does not have any member with submit invoice permission"
    end
  end
  
  def notify_time_invoice_submitted(time_invoice)
    @time_invoice=time_invoice

    group_users ||= begin
      groups = Setting.plugin_redmine_time_invoices['group_mail']
      if groups.present?
        User.active.joins(:groups).
          where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => groups)      
      end
    end

    unless group_users.nil?
      group_users_emails = Set.new
      group_users.each do |user|
        group_users_emails << user.mail
      end
      
      mail(to: group_users_emails, subject: "Time Invoice Submitted for Project: #{@time_invoice.project}")
    end   
  end
end