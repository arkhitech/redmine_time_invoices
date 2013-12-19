class TimeInvoiceMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end
  def time_invoice_notification_mail(member,time_invoice)
    @member=member
    @time_invoice=time_invoice
    mail(to: member.user.mail, subject: "TimeInvoice for Project: #{@member.project}" )
  end
  
  def notify_accounts_mail(time_invoice)
    @time_invoice=time_invoice

    group_users ||= begin
      groups = Setting.plugin_redmine_time_invoices['group_mail']
      if groups.present?
        User.active.joins(:groups).
          where("#{User.table_name_prefix}groups_users#{User.table_name_suffix}.id" => groups)      
      end
    end

    unless group_users.nil?
      group_users.each do |user|        
        mail(to: user.mail, subject: "TimeInvoice available for submission #{@time_invoice.project}")
      end
    end 
  end
end