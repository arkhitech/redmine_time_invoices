# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/time_invoices/all', to: 'time_invoices#indexall' , as: :indexall
get '/time_invoices/all/new', to: 'time_invoices#topnew' , as: :topnew

match '/time_invoice_reports/index' => 'time_invoice_reports#index', via: [:get, :post]
match '/time_invoice_reports/report' => 'time_invoice_reports#report', via: [:get, :post]

match '/time_invoice_reports/:project_id/project_index' => 'time_invoice_reports#project_index', via: [:get, :post]
match '/time_invoice_reports/:project_id/project_report' => 'time_invoice_reports#project_report', via: [:get, :post]
get '/time_invoice_reports/:project_id/project_report' => 'time_invoice_reports#project_report'

match '/feed' => 'time_invoice_reports#feed',:as => :feed, :defaults => { :format => 'atom' }, via: [:get, :post]
match '/time_invoices/indexall' => 'time_invoices#indexall', via: [:get, :post]

match '/time_invoice_charts/index' => 'time_invoice_charts#index', via: [:get, :post]
match '/time_invoice_charts/:project_id/index_for_project' => 'time_invoice_charts#index_for_project', via: [:get, :post]
match '/time_invoice_charts/group' => 'time_invoice_charts#group', via: [:get, :post]
match '/time_invoice_charts/individual' => 'time_invoice_charts#individual', via: [:get, :post]

resources :projects, only: [] do
  resources :time_invoices
  resources :time_invoice_reports
end

resources :time_invoices
resources :time_invoice_reports #check index duplicate
