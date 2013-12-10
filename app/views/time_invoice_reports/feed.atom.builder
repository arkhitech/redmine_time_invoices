xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Time Invoices"
    xml.description "Report For Filtered Time Invoices Details "
    url = url_for(:controller => 'time_invoice_reports',:action => 'report', :only_path => false)
    xml.link "rel" => "alternate", "href" => url

    for time_invoice_detail in @time_invoice_details
       itemt = time_invoice_detail.time_invoice
      xml.item do
        xml.title "Invoice ID :".concat(itemt.id.to_s)
         xml.link time_invoice_url(itemt)
#         xml.description "Start Date:".concat(itemt.start_date.to_s).
#                   concat("End Date:").concat(itemt.end_date.to_s).
#                   concat("Project:").concat(itemt.project.name.to_s).
#                   concat("Submitted By:").concat(itemt.submitted_by.name.to_s)+'<br/>'+"asdasd"
                   
         xml.description "Start Date    :".concat(itemt.start_date.to_s)+'<br/>'+
                         "End Date      :".concat(itemt.end_date.to_s)+'<br/>'+
                         "Project       :".concat(itemt.project.name.to_s)+'<br/>'+
                         "Submitted By  :".concat(itemt.submitted_by.name.to_s)+'<br/>'+
                         "Comment       :".concat(itemt.comment)+'<hr>'
               
           
#      xml.content "type" => "html" do
#        xml.text! textilizable(itemt, :comment, :only_path => false)
#      end  
                   
#        xml.pubDate post.posted_at.to_s(:rfc822)      
#        xml.guid post_url(post)
      end
    end
  end
end




#xml.instruct!
#xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
#  xml.title   truncate_single_line(@title, :length => 100)
#  xml.link    "rel" => "self", "href" => url_for(params.merge(:only_path => false))
#  xml.link    "rel" => "alternate", "href" => url_for(params.merge(:only_path => false, :format => nil, :key => nil))
#  xml.id      url_for(:controller => 'time_invoice_reports', :only_path => false)
#  xml.updated((@items.first ? @items.first.created_at : Time.now).xmlschema)
#  xml.author  { xml.name "#{Setting.app_title}" }
#  xml.generator(:uri => Redmine::Info.url) { xml.text! Redmine::Info.app_name; }
#  
#  @items.each do |item|
#    xml.entry do
#      url = url_for(:controller => 'time_invoice_reports', :only_path => false)
#      
#      xml.link "rel" => "alternate", "href" => url
#      xml.id url
#      xml.updated item.updated_at.xmlschema
#      author = item.user_id.to_s if item.respond_to?(:user_id)
#      xml.author do
#        xml.name(author)
#        xml.email(author.mail) if author.is_a?(User) && !author.mail.blank? && !author.pref.hide_mail
#      end if author
#      xml.content "type" => "html" do
#        xml.text! textilizable(item, :comment, :only_path => false)
#      end
#    end
#  end
#end

#atom_feed :language => 'en-US' do |feed|
#  feed.title @title
#  feed.updated @updated
#
#  @time_invoice_details.each do |time_invoice_details|
#    item = time_invoice_details.time_invoice
##    next if item.updated_at.blank?
#    feed.entry( item ) do |entry|
#      entry.url time_invoice_report_url(item)
#      entry.id item.id
#      entry.comment item.comment, :type => 'html' 
#      # the strftime is needed to work with Google Reader.
#      entry.updated(item.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) 
#
##      entry.author do |author|
##        author.name entry.author_name)
##      end
#    end
#  end
#end

