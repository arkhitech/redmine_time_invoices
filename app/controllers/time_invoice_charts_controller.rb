class TimeInvoiceChartsController < ApplicationController
  unloadable


  def index
    
     @all_users = User.active.sort_by{|e| e[:firstname]}
    #      start_date=Date.today.to_formatted_s(:db)

    if params[:time_invoice_chart]
      start_date = params[:time_invoice_chart][:date_from]
      end_date   = params[:time_invoice_chart][:date_to]
      user       = params[:time_invoice_chart][:selected_user]

    else
      params[:time_invoice_chart]={}
      params[:time_invoice_chart][:date_from]=Date.today - 1.year
      params[:time_invoice_chart][:date_to]= Date.today
      params[:time_invoice_chart][:selected_user]=User.current.id
      params[:time_invoice_chart][:group]=nil
      start_date = Date.today - 1.year
      end_date   = Date.today
      user       = User.current.id
     end
    
#    if its second time
#    if !params[:time_invoice_chart]
#       
#      start_date=Date.today-1.year
#      #      start_date.to_formatted_s(:db)
#      #      start_date_custom=start_date
#      #      start_date_custom.gsub! '-', ','
#      
#      end_date=Date.today
#      #      end_date.to_formatted_s(:db)
#      #      end_date_custom=end_date
#      #      end_date_custom.gsub! '-', ','  
#    else
    
      
#      pr=params[:time_invoice_chart]
#    
#      unless pr.blank? || pr.nil?
#      
#      start_date=Date.today-1.year
#      end_date=Date.today
#    
#      end
      
      time_invoice_chart = TimeInvoiceChart.new(params[:time_invoice_chart])
#      time_invoice_chart.initialize(params[:time_invoice_chart])
      if !time_invoice_chart.valid?
        flash[:error] = time_invoice_chart.errors.full_messages.join("\n")
        
      else
        @time_invoice_details = time_invoice_chart.generate
        @time_invoice_details_individual=time_invoice_chart.generate_individual
        flash[:error] = 'No Results Found!' if @time_invoice_details.blank?
        flash[:error] = 'No Results Found!' if @time_invoice_details_individual.blank?
      
#    end    
#      puts "Start Date : #{start_date} Custom #{start_date_custom} End Date #{end_date} Custom #{end_date_custom} "    
#      The format of dates giving Error
#      #start and end date come here
#      workingdays=(Date::civil(2013,1,16)..Date::civil(2014,1,16)).count {|date| date.wday >= 1 && date.wday <= 5}
#      puts "working days ================================== #{workingdays}"
    
#------------------------------------------------------------------------------------------------------------------------

      workingdays=time_invoice_chart.find_working_days
#       workingdays=20
#------------------------------------------------------------------------------------------------------------------------

    if Redmine::Plugin.installed?(:redmine_leaves)
      
        # check how many total holidays were taken else working days
      total_leaves=time_invoice_chart.find_all_group_leaves(start_date, end_date)
      total_leaves_individual=time_invoice_chart.find_individual_leaves(start_date, end_date,user)
       

      else
       total_leaves=0
       total_leaves_individual=0
    end
      
      total_user_count=time_invoice_chart.get_unique_all_or_group_users.count
#      ActiveRecord::Base.logger.debug "#{'+'*80}\nTotal User Count #{selected_users.count}"
      puts "#{'+'*80}\nSelcted Users Count #{total_user_count} #{time_invoice_chart.get_unique_all_or_group_users}"
      
     
#-------------------------------------REAL DATA FLOW-----------------------------------------------------------------------------------
#        @time_invoice_details.each do |time_invoice_details|
#          time_invoice_details.sum("orders_count")
#          time_invoice_details.invoiced_hours
#        end
#        
#       
       total_logged_hours=@time_invoice_details.sum('logged_hours')
       puts "#{'+'*80}\nTotal Logged Hours #{total_logged_hours}"
       total_billed_hours=@time_invoice_details.sum('invoiced_hours')
       puts "#{'+'*80}\nTotal Logged Hours #{ total_billed_hours}"
       
      #group all
       total_working_hours=((workingdays*total_user_count)-total_leaves)*8                         #date from the drop down
       logged_time=total_logged_hours                                           #from time_invoice_details    
       billable_time=[total_working_hours, logged_time].max 
       unlogged_time=billable_time-logged_time 
       billed_time= total_billed_hours 
       unbilled_time=billable_time-billed_time
       
      puts "Total Working Hours:  #{total_working_hours} 
               Logged Time: #{logged_time} Billable Time #{billable_time}
               Billed Time #{billed_time} Unbilled Time #{unbilled_time}
               Total Leaves #{ total_leaves}"
      
      
      billed_time_ratio=((billed_time*100).to_f/billable_time).to_f.round(2)
      unbilled_time_ratio=((unbilled_time*100).to_f/billable_time).to_f.round(2)
      
      puts "Billed Time Ratio: #{billed_time_ratio}  Unbilled Time Ratio #{unbilled_time_ratio}"
      
      
      # Individual
      
       total_logged_hours_individual=@time_invoice_details_individual.sum('logged_hours')
       puts "#{'+'*80}\nTotal Logged Hours individual #{total_logged_hours}"
       total_billed_hours_individual=@time_invoice_details_individual.sum('invoiced_hours')
       puts "#{'+'*80}\nTotal Logged Hours Individual #{ total_billed_hours}"
       
           puts "Working Days  #{workingdays} Total Leaves #{total_leaves_individual}"
            
       total_working_hours_individual=(workingdays-total_leaves_individual)*8
       logged_time_individual=total_logged_hours_individual
       billable_time_individual=[total_working_hours_individual,logged_time_individual].max
       unlogged_time_individual= billable_time_individual-logged_time_individual
       billed_time_individual=total_billed_hours_individual #invoiced time from time_invoice_details
       unbilled_time_individual=billable_time_individual-billed_time_individual
      
        puts "individual Total Working Hours:  #{total_working_hours_individual} 
               individual Logged Time: #{logged_time_individual} individual Billable Time #{billable_time_individual}
               individual Billed Time #{billed_time_individual} individual Unbilled Time #{unbilled_time_individual}
               individual Total Leaves #{ total_leaves_individual}"
      
       billed_time_ratio_individual=((billed_time_individual*100).to_f/billable_time_individual).to_f.round(2)
      unbilled_time_ratio_individual=((unbilled_time_individual*100).to_f/billable_time_individual).to_f.round(2)
      
      puts "Billed Time Ratio: #{billed_time_ratio_individual}  Unbilled Time Ratio #{unbilled_time_ratio_individual}"
      
     
    
      end #if condition ends
    
 #-------------------------------------------------------------------------------------------------------------   
    
    @barchart_billable_vs_billed_vs_logged = LazyHighCharts::HighChart.new('graph') do |f|
    
    f.title({ :text=>"Billable vs. Logged vs. Billed Time - Bar Chart All/Group"})
    f.options[:xAxis][:categories] = ['Time Parameters']
    f.labels(:items=>[:html=>"Total Invoices Summary", :style=>{:left=>"30px", :top=>"8px", :color=>"black"} ])      
    f.series(:type=> 'column',:name=> 'Billable',:data=> [billable_time])
    f.series(:type=> 'column',:name=> 'Logged',:data=> [logged_time])
    f.series(:type=> 'column', :name=> 'Billed',:data=> [billed_time])
  end
    
  #if condition changes above variables  
    
    
    @chart_billed_unbilled_vs_billable = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [40,40,40,40]} )

      
      series = {
               :type=> 'pie',
               :name=> 'Billed and unbilled time against billable time in total/group',
               :data=> [
                  ['Un Billed Time',       unbilled_time],
                  {
                     :name=> 'Billed Time',    
                     :y=> billed_time,
                     :sliced=> true,
                     :selected=> true
                  }
                  
               ]
      }
      
      
      f.series(series)
      f.options[:title][:text] = "Billed Vs Un-Billed "
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        }
      })
    end
    

    
    #Pie Chart 2
       @chart_logged_unlogged_vs_billable = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [40,40,40,40]} )

      
      series = {
               :type=> 'pie',
               :name=> 'Logged and unLogged time against billable time in total/group',
               :data=> [
                  ['Un Logged Time',       unlogged_time],
                  {
                     :name=> 'Logged Time',    
                     :y=> logged_time,
                     :sliced=> true,
                     :selected=> true
                  }
                  
               ]
      }
      
      
      f.series(series)
      f.options[:title][:text] = "Logged Vs Un-Logged"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        }
      })
    end
    
    
    
    #INDOVIDUAL GRAPHS
    
     @barchart_indv_billable_vs_billed_vs_logged = LazyHighCharts::HighChart.new('graph') do |f|
    
    f.title({ :text=>"Billable vs. Logged vs. Billed Time - Bar Chart Individual"})
    f.options[:xAxis][:categories] = ['Time Parameters']
    f.labels(:items=>[:html=>"Total Invoices Summary", :style=>{:left=>"30px", :top=>"8px", :color=>"black"} ])      
    f.series(:type=> 'column',:name=> 'Billable',:data=> [billable_time_individual])
    f.series(:type=> 'column',:name=> 'Logged',:data=> [logged_time_individual])
    f.series(:type=> 'column', :name=> 'Billed',:data=> [billed_time_individual])
  end
    
  #if condition changes above variables  
    
    
    @chart_indv_billed_unbilled_vs_billable = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [40,40,40,40]} )

      
      series = {
               :type=> 'pie',
               :name=> 'Billed and unbilled time against billable time individual',
               :data=> [
                  ['Individual :Un Billed Time',       unbilled_time_individual],
                  {
                     :name=> 'Billed Time',    
                     :y=> billed_time_individual,
                     :sliced=> true,
                     :selected=> true
                  }
                  
               ]
      }
      
      
      f.series(series)
      f.options[:title][:text] = "Individual: Billed Vs Un-Billed "
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        }
      })
    end
    

    
    #Pie Chart 2
       @chart_indv_logged_unlogged_vs_billable = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [40,40,40,40]} )

      
      series = {
               :type=> 'pie',
               :name=> 'Logged and unLogged time against billable time individual',
               :data=> [
                  ['Un Logged Time',       unlogged_time_individual],
                  {
                     :name=> 'Logged Time',    
                     :y=> logged_time_individual,
                     :sliced=> true,
                     :selected=> true
                  }
                  
               ]
      }
      
      
      f.series(series)
      f.options[:title][:text] = "Individual: Logged Vs Un-Logged"
      f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}) 
      f.plot_options(:pie=>{
        :allowPointSelect=>true, 
        :cursor=>"pointer" , 
        :dataLabels=>{
          :enabled=>true,
          :color=>"black",
          :style=>{
            :font=>"13px Trebuchet MS, Verdana, sans-serif"
          }
        }
      })
    end
    
  end

  def individual
  end

  def group
  end
end
