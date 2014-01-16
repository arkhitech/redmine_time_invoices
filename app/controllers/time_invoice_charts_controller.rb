class TimeInvoiceChartsController < ApplicationController
  unloadable


  def index
    
     @all_users = User.active.sort_by{|e| e[:firstname]}
    #      start_date=Date.today.to_formatted_s(:db)
      start_date=Date.today-1.year
#      start_date.to_formatted_s(:db)
       start_date_custom=start_date
#      start_date_custom.gsub! '-', ','

      end_date=Date.today
#      end_date.to_formatted_s(:db)
       end_date_custom=end_date
#      end_date_custom.gsub! '-', ','
      
      puts "Start Date : #{start_date} Custom #{start_date_custom} End Date #{end_date} Custom #{end_date_custom} "
      
      #The format of dates giving Error
      
      #start and end date come here
      workingdays=(Date::civil(2013,1,16)..Date::civil(2014,1,16)).count {|date| date.wday >= 1 && date.wday <= 5}
      puts "working days ================================== #{workingdays}"
      
      
#      if Setting.plugin_redmine_timesheet_plugin.present? && Setting.plugin_redmine_timesheet_plugin['user_status'] == 'all'
        # check how many total holidays were taken else working days       

       
       total_leaves=UserLeave.where(leave_date: start_date..end_date).count
       
      #  
      #else
      # total_leaves=0
      #end
      
       total_working_hours=(workingdays-total_leaves)*8                         #date from the drop down
       logged_time=450                                            #from time_invoice_details
       billable_time=[total_working_hours, logged_time].max
       unlogged_time=billable_time-logged_time
       billed_time=500                                            #invoiced time from time_invoice_details
       unbilled_time=billable_time-billed_time 
      
         puts "Total Working Hours:  #{total_working_hours} 
               Logged Time: #{logged_time} Billable Time #{billable_time}
               Billed Time #{billed_time} Unbilled Time #{unbilled_time}
               Total Leaves #{ total_leaves}"
      
      billed_time_ratio=((billed_time*100).to_f/billable_time).to_f.round(2)
      unbilled_time_ratio=((unbilled_time*100).to_f/billable_time).to_f.round(2)
      
      puts "Billed Time Ratio: #{billed_time_ratio}  Unbilled Time Ratio #{unbilled_time_ratio}"
    
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
    f.series(:type=> 'column',:name=> 'Billable',:data=> [billable_time])
    f.series(:type=> 'column',:name=> 'Logged',:data=> [logged_time])
    f.series(:type=> 'column', :name=> 'Billed',:data=> [billed_time])
  end
    
  #if condition changes above variables  
    
    
    @chart_indv_billed_unbilled_vs_billable = LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({:defaultSeriesType=>"pie" , :margin=> [40,40,40,40]} )

      
      series = {
               :type=> 'pie',
               :name=> 'Billed and unbilled time against billable time individual',
               :data=> [
                  ['Individual :Un Billed Time',       unbilled_time],
                  {
                     :name=> 'Billed Time',    
                     :y=> billed_time,
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
