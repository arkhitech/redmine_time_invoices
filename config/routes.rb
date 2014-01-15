# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/time_invoices/all', to: 'time_invoices#indexall' , as: :indexall
get '/time_invoices/all/new', to: 'time_invoices#topnew' , as: :topnew

match '/time_invoice_reports/test' => 'time_invoice_reports#test'
match '/time_invoice_reports/index' => 'time_invoice_reports#index'
match '/time_invoice_reports/project_index' => 'time_invoice_reports#project_index'
match '/time_invoice_reports/report' => 'time_invoice_reports#report'
match '/feed' => 'time_invoice_reports#feed',:as => :feed, :defaults => { :format => 'atom' }
match '/time_invoices/indexall' => 'time_invoices#indexall'

match '/time_invoice_charts/index' => 'time_invoice_charts#index'
match '/time_invoice_charts/group' => 'time_invoice_charts#group'
match '/time_invoice_charts/individual' => 'time_invoice_charts#individual'

resources :projects, only: [] do
  resources :time_invoices
end

resources :time_invoices
resources :time_invoice_reports #check index duplicate
