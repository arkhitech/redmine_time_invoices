module TimeInvoiceReportsHelper
  

  include ActionView
  
  
   def options_for_operator_type(operator_value)
    options_for_select([['greater-than'],
                        ['less-than']],
                        operator_value)
  end
  
   
#   def group_options(timesheet)
  def select_group_options(time_invoice_reports)
    available_groups = Group.all
    selected_groups = time_invoice_reports
    options_from_collection_for_select(available_groups, :id, :name, :selected => selected_groups)
  end
  
def submitted_by_user_options(selected_user)
   options_from_collection_for_select(eligible_to_submit_invoices_users, :id, :name, selected_user)
 end
 
def eligible_to_submit_invoices_users
#    user_ids = Setting.plugin_time_invoices['eligible_to_submit_invoices_users']
#    if user_ids.blank?
#      User.active.all
#    else
#      User.active.joins(:users).
#      where("#{User.table_name_prefix}users#{User.table_name_suffix}.id" => 
#        user_ids).group("#{User.table_name}.id")
#    end
#  end
   User.active.all
   end
end
