module TimeInvoiceChartsHelper
  
  include ActionView
  include QueriesHelper
  include ApplicationHelper
  include TimeInvoiceReportsHelper
  
  def custom_format(time)
  Time::DATE_FORMATS[:w3cdtf] = lambda { |time| time.strftime("%Y,%m,%d# {time.formatted_offset}") }
  end
  
end
