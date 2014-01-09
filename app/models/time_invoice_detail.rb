class TimeInvoiceDetail < ActiveRecord::Base
  unloadable
  belongs_to :time_invoice
  belongs_to :user
  before_save :reset_protected_attributes
  validates :user_id, uniqueness: {scope: :time_invoice_id}
  validate :validate_invoiced_quantity_input
  
  def reset_protected_attributes
    reset_invoiced_hours 
    reset_logged_hours
  end
  private :reset_protected_attributes
  
  def reset_logged_hours
    id=self.time_invoice.project_id
    child_projects = Project.find(id).descendants
    child_projects.collect{|u| u.id}
    child_projects << id
    self.logged_hours = TimeEntry.where(
      project_id: child_projects,
      spent_on: self.time_invoice.start_date..self.time_invoice.end_date,
      user_id: self.user_id
    ).sum(:hours)
  end
  
  def logged_hours
    read_attribute(:logged_hours) || reset_logged_hours
    #    read_attribute(:logged_hours) || reset_logged_hours
  end
    
  def reset_invoiced_hours
    case invoiced_unit
    when 'month'
      self.invoiced_hours = invoiced_quantity * 176
    else      
      self.invoiced_hours = invoiced_quantity
    end
  end
  private :reset_invoiced_hours
  
  def validate_invoiced_quantity_input
    unless invoiced_quantity.present?
      errors.add(:invoiced_quantity, 'is a required field')
    end
    
    if invoiced_quantity.to_f < 0
      errors.add(:invoiced_quantity, 'cannot be less than 0')
    end

    return unless invoiced_unit.present?
    
    if invoiced_unit=='month' && invoiced_quantity.to_f > 1
      errors.add(:invoiced_quantity, 'cannot be greater than 1 for monthly invoicing')
    elsif invoiced_unit!='month' && (invoiced_quantity.to_f < 1 && invoiced_quantity.to_f != 0)
      errors.add(:invoiced_quantity, 'cannot be less than 1 for hourly invoicing')
    end
  end
end
