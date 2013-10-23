class TimeInvoiceMailer < ActionMailer::Base
  default from: 'no_reply@Time_Invoice_Plugin'
  def time_invoice_notification_mail(member,time_invoice)
    @member=member
    @time_invoice=time_invoice
    mail(to: member.user.mail, subject: "Notification TimeInvoice for Project #{@member.project}" )
  end
  
  def notify_accounts_mail(time_invoice)
    @time_invoice=time_invoice
    mail(to: Setting.plugin_redmine_time_invoices['mail'], subject: "TimeInvoice available for submission #{@time_invoice.project}")
  end
end