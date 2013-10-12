# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
<<<<<<< HEAD

get '/time_invoices/all', to: 'time_invoices#indexall' , as: :indexall
resources :projects, only: [] do
  resources :time_invoices
end

resources :time_invoices
=======
get 'time_invoices', :to => 'time_invoices#index'
>>>>>>> 7b8cb405674ed3941ef7151d0dc7b29f823cba97
