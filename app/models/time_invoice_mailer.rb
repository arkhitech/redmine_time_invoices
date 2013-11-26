class TimeInvoiceMailer < ActionMailer::Base
  layout 'mailer'
  default from: Setting.mail_from
  def self.default_url_options
    Mailer.default_url_options
  end
  def time_invoice_notification_mail(user,time_invoice)
    @user=user
    @time_invoice=time_invoice
    mail(to: @user.mail, subject: "TimeInvoice for Project: #{@time_invoice.project}" )
  end
  
  def notify_accounts_mail(time_invoice)
    @time_invoice=time_invoice
    mail(to: Setting.plugin_redmine_time_invoices['mail'], subject: "TimeInvoice available for submission #{@time_invoice.project}")
  end
end