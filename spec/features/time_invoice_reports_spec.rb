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
    it "should show reports Results when Apply is pressed and Result exists for parameters" do
      select('Greater Than [>]', :from => 'time_invoice_report[logged_operator_value]')
      fill_in "time_invoice_report[logged_time_compared_hours]", :with => '2.0'
#      @time_invoice_detail = TimeInvoiceDetail.find_by_logged_hours('3.0')
      click_button("Apply")
      expect(page).to have_content('Time Invoices Report Results')
      expect(page).to have_content('Invoice ID')
      #         expect(page).to have_selector?('table tr')

    end 
    
    #logged time for which result does not exists
    it "should give a flash error if no results exist for supplied parameters" do
      select('Greater Than [>]', :from => 'time_invoice_report[logged_operator_value]')
      fill_in "time_invoice_report[logged_time_compared_hours]", :with => '20.0'
      click_button("Apply")
      expect(page).to have_content('No Results Found!')
    end 
    
#    #invoiced time for which result exists
#    it "should show reports Results when Apply is pressed and Result exists for parameters" do
#      select('Greater Than [>]', :from => 'time_invoice_report[invoiced_operator_value]')
#      fill_in "time_invoice_report[invoiced_time_compared_hours]", :with => '5'
#      click_button("Apply")
#      expect(page).to have_content('Time Invoices Report Results')
#    end 
    
    
    
    
  end
  
  
end #Main do ending