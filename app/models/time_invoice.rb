class TimeInvoice < ActiveRecord::Base
  unloadable
  belongs_to :project
  has_many :time_invoice_details, dependent: :destroy
  belongs_to :submitted_by, class_name: User.name   
  accepts_nested_attributes_for :time_invoice_details
  validate :correctness_of_date, :overlapping
  after_save :notify_the_concerned_person

  
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

  def notify_the_concerned_person
    unless self.submitted_by.nil?
      TimeInvoiceMailer.notify_accounts_mail(self).deliver
    
    else
      users=[]
      members = self.project.users
      members.each do |member|
        if User.exists?(member.id)
          users << User.find(member.id)
        else
          users << Group.find(member.id).users
        end
      end
      users=users.flatten.uniq
      users.delete_if{|user| !user.allowed_to?(:submit_invoiceable_time,self.project)}
      unless users.blank?        
        users.each {|user| TimeInvoiceMailer.
            time_invoice_notification_mail(user,self).deliver 
        }
      end
    end
  end
  private :notify_the_concerned_person
  
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
      if time_invoices.count!=1 && !array_ids.include?(id)
        errors.add(:Overlapping, ":Time invoices cannot overlap,Change the date range")
      end
        
    end
  end
end

