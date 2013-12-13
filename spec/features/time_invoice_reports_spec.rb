require 'spec_helper'

describe "TimeInvoiceReports" do
  #works for all users to get them login
  before (:all) do
   
    TimeInvoice.destroy_all
    TimeInvoiceDetail.destroy_all
    @user=User.find_by_login('admin')
    @user ||= begin
      user = User.new(firstname: "test", lastname: "user", mail: "test@user.com")
      user.login = "testuser"
      user.password = "testuser"
      user.save!
      user
    end
    User.stubs(:current).returns(@user)
   
        
    @project = Project.find_by_name('testproject')
    @project ||= begin
      project = Project.create!(id: 1, name: 'testproject', description: 'text', 
        homepage: "", is_public: true, parent_id: nil, identifier: 'testproject', 
        status: 1, inherit_members: false)
      project.enable_module!(:time_invoices)
      project
    end
    
    @time_invoice = TimeInvoice.find_by_start_date('2013-10-01')
    @time_invoice ||= begin
      time_invoice = TimeInvoice.new(start_date: "2013-10-01".to_date, 
        end_date: "2013-10-31".to_date, project_id: @project.id,
        comment: "no comments")
      time_invoice.save!
      time_invoice
    end
    

     
    
    @time_invoice_detail = TimeInvoiceDetail.find_by_logged_hours(3.0)
    @time_invoice_detail ||= begin
      time_entry = TimeEntry.new(hours: 3.0, activity_id: 1, spent_on: '2013-10-02')
      time_entry.project_id = @project.id 
      time_entry.user_id =  @user.id
      time_entry.save!
      
      time_invoice_detail = TimeInvoiceDetail.new(time_invoice_id: @time_invoice.id,logged_hours: 3.0,
        invoiced_hours: 5.0,invoiced_quantity: 5.0, comment: "no comments", user_id: @user.id)
      time_invoice_detail.save!
      time_invoice_detail
    end
    
#    @time_invoice_mailer ||= begin
#      time_invoice_mailer==TimeInvoiceMailer.new(notify_accounts_mail, @time_invoice)
#      time_invoice_mailer.save!
#    end
  
  end
 


  describe "time_invocie_reports/index" do

    it "Should have the content 'Time Invoices Report'" do
      visit '/time_invoice_reports/index'
      expect(page).to have_content('Time Invoices Report')
      expect(page).to have_content('Start Date Range')
      expect(page).to have_content('End Date Range')
      expect(page).to have_content('To')
      expect(page).to have_content('From')
      expect(page).to have_content('User And Group Filters')
      expect(page).to have_content('User')
      expect(page).to have_content('Group')
      expect(page).to have_content('Submitted By User')
      expect(page).to have_content('Time Filters')
    end
    
    it "click back should display all time invoices'" do
      visit '/time_invoice_reports/index'
      click_link("Back")
      current_path.should eq indexall_path
      
    end
    
  end #First do ends

  describe "time_invocie_reports/reports" do
    
    
    before(:each) do
      visit("/")
      click_link("Time invoices") 
      click_link("View Time Invoice Report")
    end
    
  
    #no parameters selected
    it "should show show error when Apply is pressed and no parameters sent" do
      click_button("Apply")
      expect(page).to have_content('No Results For Empty Filters ----|---- Please Choose Atleast One Report Generation Parameter!')
    end   
    
   
    #logged time for which result exists
    it "should show reports Results when Apply is pressed and Result exists for
                                         logged time and operator parameters" do
      select('Greater Than [>]', :from => 'time_invoice_report[logged_operator_value]')
      fill_in "time_invoice_report[logged_time_compared_hours]", :with => '2.0'
      #      @time_invoice_detail = TimeInvoiceDetail.find_by_logged_hours('3.0')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
      #         expect(page).to have_selector?('table tr')

    end 
    
    #logged time for which result does not exists
    it "should give a flash error if no results exist for logged time and operator parameters" do
      select('Less Than [<]', :from => 'time_invoice_report[logged_operator_value]')
      fill_in "time_invoice_report[logged_time_compared_hours]", :with => '20.0'
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end 
    
    #invoiced time for which result exists
    it "should show reports Results when Apply is pressed and Result exists for
                                       invoiced time and operator parameters" do
      select('Greater Than [>]', :from => 'time_invoice_report[invoiced_operator_value]')
      fill_in "time_invoice_report[invoiced_time_compared_hours]", :with => '4'
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
    
    #invoiced time for which result  do not exists
    it "should give a flash error if no results exist for invoiced time and operator parameters" do
      select('Less Than [<]', :from => 'time_invoice_report[invoiced_operator_value]')
      fill_in "time_invoice_report[invoiced_time_compared_hours]", :with => '4'
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end 
    
    #start date for which result  exist and are displayed
    it "should show report results with correct Start Date Range parameters" do
      fill_in "time_invoice_report[start_date_from]", :with => '2013-09-31'
      fill_in "time_invoice_report[start_date_to]", :with => '2013-10-03'
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
       
    
    #end_date for which result  do not exists
    it "should give a flash error if no results exist for Start Date Range parameters" do
      fill_in "time_invoice_report[start_date_from]", :with => '2013-10-02'
      fill_in "time_invoice_report[start_date_to]", :with => '2013-11-02'
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end 
    
    
    #end_date for which result  exist and are displayed
    it "should show report results with correct End Date Range parameters" do
      fill_in "time_invoice_report[end_date_from]", :with => '2013-10-30'
      fill_in "time_invoice_report[end_date_to]", :with => '2013-11-03'
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
       
    
    #end_date for which result  do not exists
    it "should give a flash error if no results exist for End Date Range parameters" do
      fill_in "time_invoice_report[end_date_from]", :with => '2013-10-02'
      fill_in "time_invoice_report[end_date_to]", :with => '2013-10-30'
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
    
    #selected user for which result  exist and are displayed
    it "should give report results with selected user parameters" do
      select('Redmine Admin', :from => 'time_invoice_report[selected_users][]')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
       
    
    #selected user for which result  do not exists
    it "should give a flash error if no results exist for selected user parameters" do
      select('test user', :from => 'time_invoice_report[selected_users][]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
    
    #selected multiple users for which result  exist and are displayed
    it "should give report results with multiple selected users parameters" do
      select('Redmine Admin', :from => 'time_invoice_report[selected_users][]')
      select('test user', :from => 'time_invoice_report[selected_users][]')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
    
    #selected multiple users for which result do not  exist and are displayed
    it "should give a flash error if no results exist for multiple selected groups parameters" do
      select('Asim Mushtaq', :from => 'time_invoice_report[selected_users][]')
      select('test user', :from => 'time_invoice_report[selected_users][]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end 
    
    #selected groups for which result  exist and are displayed
    it "should give report results with selected group parameters" do
      select('Admin', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
       
    
    #selected groups for which result  do not exists
    it "should give a flash error if no results exist for selected group parameters" do
      select('Developers', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
    #selected multiple groups for which result  exist and are displayed
    it "should give report results with multiple selected groups parameters" do
      select('Admin', :from => 'time_invoice_report[groups][]')
      select('Developers', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
    
    #selected multiple groups for which result do not  exist and are displayed
    it "should give a flash error if no results exist for multiple selected groups parameters" do
      select('Developers', :from => 'time_invoice_report[groups][]')
      select('Graphic desingers', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
    #selected user for which result  exist, selected group results does not exist | Results displayed
    it "should give report results with valid selected user but invalid user group" do
      select('Redmine Admin', :from => 'time_invoice_report[selected_users][]')
      select('Developers', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
    end 
    
    #selected user and group for which results do not exist
    it "should give a flash error if no results exist for selected group and user parameters" do
      select('test user', :from => 'time_invoice_report[selected_users][]')
      select('Developers', :from => 'time_invoice_report[groups][]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
    
    #submitted by user for which results do not exist
    it "should give a flash error if no results exist for submitted by user parameter" do
      select('test user', :from => 'time_invoice_report[submitted_by_user]')
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end
    
  end
  
  
  describe "Goto [time_invocies/all] | Submit Invoice | then Submitted By " do
    
    
    before(:each) do
      #permissions to submit invoice able time
      visit("/")
      click_link("Time invoices") 
#      visit(edit_time_invoice_path(@time_invoice)) # goes to   current_path.should eq edit_time_invoice_path(@time_invoice)
      click_link("Edit/Submit")
      
      #Required fields
      fill_in "time_invoice[time_invoice_details_attributes][1][invoiced_quantity]", :with => 5.0
      fill_in "time_invoice[time_invoice_details_attributes][1][comment]", :with => 'just updated'
      
      #Allowed to submit permission
      User.stubs(:allowed_to?).with(:submit_invoiceable_time , @time_invoice.project).returns(true)
      TimeInvoice.stubs(:allowed_to_submit?).with(@time_invoice).returns(true) #return true if allowed to 
      
#      @time_invoice.update_attributes(submitted_by_id: @user.id)
#      @time_invoice.save!
#      TimeInvoice.stubs(:notify_the_concerned_person).returns(false)
      
      click_button("Update Time invoice") # goes to current_path.should eq. time_invoice_path(@time_invoice)
  
    end
    
    #submitted by user for which results exist
    it "should show report results which exist for submitted by user parameter" do
            current_path.should eq time_invoice_path(@time_invoice)
            visit("/time_invoices/indexall")
      #      click_link("View")
      #      IF VIEW EXISTS MEANS THE REPORT HAS BEEN SUBMITTED
      #      select('Redmine Admin', :from => 'time_invoice_report[submitted_by_user]')
      #      click_button("Apply")
      #      expect(page).to have_content('Time Invoices Report Results')
      #      expect(page).to have_content('Invoice ID')
      
    end
    
    #submitted by user for which results does not exist
        it "should give a flash error if no results exist for submitted by user parameter" do
          visit("/time_invoices/indexall")
          click_link("View Time Invoice Report")
          select('test user', :from => 'time_invoice_report[submitted_by_user]')
          click_button("Apply")
          expect(page).to have_content('No Results Found!')
          
        end
    
    
    
  end # Submitted by Block Ends
  
end #Main do ending