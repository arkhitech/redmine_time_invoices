require 'spec_helper'

describe "time_invoices/index.html.erb" do
  before :all do
    TimeInvoice.destroy_all
    @user = User.find_by_login('testuser')
    @user ||= begin
      user = User.new(firstname: 'test', lastname: 'user', mail: 'arkhitech@test.com')
      user.login = 'testuser'
      user.password = 'testing123'
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
  end
  
  it "should display all time invoices" do
    visit("/")
    click_link("Time invoices")
    current_path.should eq indexall_path
  end
  
  it "should display edit time invoice page" do
    visit("/time_invoices/all")
    click_link("Edit/Submit")
    current_path.should eq edit_time_invoice_path(@time_invoice)
  end
  
  it "should allow to submit edited time invoice" do
    visit(edit_time_invoice_path(@time_invoice))
    click_button("Update Time invoice")
    current_path.should eq time_invoice_path(@time_invoice)
  end
  
  describe "testing for time invoice show" do
    before(:each) do
      visit("/")
      click_link("Time invoices")
      click_link("Edit/Submit")
      click_button("Update Time invoice")
    end
    it "should display time invoice details" do
    
      visit("/time_invoices/all")
      click_link("View")
      current_path.should eq time_invoice_path(@time_invoice)
    end
  end
  
  
end