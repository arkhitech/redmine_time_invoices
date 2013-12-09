class TimeInvoice < ActiveRecord::Base
  unloadable
  belongs_to :project
  has_many :time_invoice_details, dependent: :destroy
  belongs_to :submitted_by, class_name: User.name   
  accepts_nested_attributes_for :time_invoice_details
  validate :correctness_of_date, :overlapping
  after_save :notify_the_concerned_person

  
  def build_time_invoice_details
    user_hours = TimeEntry.group(:user_id).where(
      project_id: self.project_id,
      spent_on: self.start_date..self.end_date
    ).sum(:hours)
    user_hours.each_pair do |user_id, hours|
      self.time_invoice_details.build(
        user_id: user_id,
        logged_hours: hours,
      )
    end
  end

  def notify_the_concerned_person
    unless self.submitted_by.nil?
      TimeInvoiceMailer.notify_accounts_mail(self).deliver
    end
  end
  private :notify_the_concerned_person
  
  def correctness_of_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:Date_format, ": 'end date' less than 'start date' is not permitted")
    end
  end
def overlapping
    time_invoices=TimeInvoice.where("project_id=? AND ((start_date<=? AND end_date>=?) OR (start_date<=? AND end_date>=?))", project_id,start_date,start_date,end_date,end_date)
    puts "#{"*"*300}these are the results we got form sir's query#{time_invoices.inspect},#{time_invoices.count}"
    array_ids=time_invoices.collect{|ti| ti.id}
    puts "#{'*'*300}this is the collection of IDS: #{array_ids}"
    if time_invoices.count>0 && !array_ids.include?(id)
      errors.add(:Overlapping, ":Time invoices cannot overlap,Change the date range")
    end
  end
end

