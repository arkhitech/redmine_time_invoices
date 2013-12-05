module TimeInvoiceReportsHelper
  

  include ActionView


   def options_for_operator_type(operator_value)
    options_for_select([['Greater Than [>]','>'],
                        ['Less    Than [<]','<']],
                        operator_value)
#                      
#     options_for_select([['Choose Operator',0],
#                        ['>',1],
#                        ['<',2]],
#                        operator_value)
                     
  end
  
   

  def select_group_options(selected_groups_from_view)
    available_groups = Group.all
    selected_groups = selected_groups_from_view
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
