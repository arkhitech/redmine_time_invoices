# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/time_invoices/all', to: 'time_invoices#indexall' , as: :indexall
resources :projects, only: [] do
  resources :time_invoices
end

resources :time_invoices
