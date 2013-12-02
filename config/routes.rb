# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/time_invoices/all', to: 'time_invoices#indexall' , as: :indexall
get '/time_invoices/all/new', to: 'time_invoices#topnew' , as: :topnew

match '/time_invoice_reports/test' => 'time_invoice_reports#test'
match '/time_invoice_reports/index' => 'time_invoice_reports#index'
match '/time_invoice_reports/report' => 'time_invoice_reports#report'
#match '/time_invoice_reports/test', to: 'time_invoice_reports#test' , as: :test

resources :projects, only: [] do
  resources :time_invoices
  #resources :time_invoice_reports
end

resources :time_invoices