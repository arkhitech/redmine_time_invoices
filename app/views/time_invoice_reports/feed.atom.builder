xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Time Invoices"
    xml.description "Report For Filtered Time Invoices Details "
    url = url_for(:controller => 'time_invoice_reports',:action => 'report', :only_path => false)
    xml.link "rel" => "alternate", "href" => url

    for time_invoice_detail in @time_invoice_details
      time_invoice_item = time_invoice_detail.time_invoice
      xml.item do
        xml.title "Invoice No # ".concat(time_invoice_item.id.to_s)
        xml.link time_invoice_url(time_invoice_item)
                   
        xml.description "Start Date    :".concat(time_invoice_item.start_date.to_s)+'<br/>'+
          "End Date      :".concat(time_invoice_item.end_date.to_s)+'<br/>'+
          "Project       :".concat(time_invoice_item.project.name.to_s)+'<br/>'+
          "Submitted By  :".concat(time_invoice_item.submitted_by.name.to_s)+'<br/>'+
          "Comment       :".concat(time_invoice_item.comment)+'<hr>'
        
           #this could be done by doing parameter.to_xml    
           

      end
    end
  end
end