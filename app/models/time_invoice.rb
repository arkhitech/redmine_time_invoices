class TimeInvoice < ActiveRecord::Base
  unloadable
<<<<<<< HEAD
  belongs_to :project
  has_many :time_invoice_details
  belongs_to :submitted_by, class_name: User.name   
  accepts_nested_attributes_for :time_invoice_details
  
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
=======
>>>>>>> 7b8cb405674ed3941ef7151d0dc7b29f823cba97
end
