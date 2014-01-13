class TimeInvoice < ActiveRecord::Base
  unloadable
  belongs_to :project
  has_many :time_invoice_details, dependent: :destroy
  belongs_to :submitted_by, class_name: User.name   
  accepts_nested_attributes_for :time_invoice_details
  validate :correctness_of_date, :overlapping, :on=> :create
  after_save :notify_time_invoice_saved

  
  def build_time_invoice_details
    parent_project_id = self.project_id
    child_projects = Project.find(parent_project_id).descendants
    child_projects_id = []
    child_projects.each do |project_id|
      child_projects_id << project_id.id
    end
    projects_for_time_invoice = child_projects_id
    projects_for_time_invoice << parent_project_id
    
    user_hours = TimeEntry.group(:user_id).where(
      project_id: projects_for_time_invoice,
      spent_on: self.start_date..self.end_date
    ).sum(:hours)
    
    user_hours.each_pair do |user_id, hours|
      self.time_invoice_details.build(
        user_id: user_id,
        logged_hours: hours,
      )
    end
  end

  def notify_time_invoice_saved
    unless self.submitted_by.nil?
      TimeInvoiceMailer.notify_time_invoice_generated(self,self.project).deliver
    
    else
        TimeInvoiceMailer.notify_time_invoice_submitted(self).deliver      
    end
  end
  private :notify_time_invoice_saved
  
  def correctness_of_date
    if start_date.present? && end_date.present? && start_date > end_date
      errors.add(:Date_format, ": 'end date' less than 'start date' is not permitted")
    else
      errors.add(:start_date, "is required") if !start_date.present?
      errors.add(:end_date, "is required") if !start_date.present? 
    end
  end
  
  def overlapping
    time_invoices=TimeInvoice.where("project_id=? AND ((start_date<=? AND end_date>=?) OR (start_date<=? AND end_date>=?))", project_id,start_date,start_date,end_date,end_date)
    array_ids=time_invoices.collect{|ti| ti.id}

    
    if time_invoices.count>0 
      errors.add(:Overlapping, ":Time invoices cannot overlap,Change the date range")
    end
  end
end

