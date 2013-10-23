Redmine Time Invoices
=====================
Redmine Time Invoice plugin generates invoices for each project in redmine where 
the Redmine Invoice Generator plugin module is installed.

Functionality
==============
Rake task is responsible for generating  time invoices for each month for each 
project and email is sent to the users with permission submit_invoiceable_time.


In redmine project, all the users of the project with permission 
"submit_invoiceable_time" can view and submit time invoice for that particular 
project. These users can add comments for the invoiceable_time, and also add the 
'invoiceable_quantity', and 'invoiceable_unit' (monthly, or hourly) for each 
time logged. Once user submits invoiceable time then he can only view it.

Installation
==============
To Install this plugin goto plugins in your redmine repository
Clone the git repository: 
`git clone github.com/arkhitech/redmine_time_invoices.git`

Run the database migrations: 
`rake redmine:plugins:migrate NAME=redmine_time_invoices RAILS_ENV=production`

Restart Redmine
You should now be able to see the plugin list in Administration -> Plugins 

Setup Cron
Go to redmine_time_invoices plugins directory and `wheneverize` the downloaded plugin directory.
Open config directory and and edit schedule.rb

for example:

	set :environment, "production"
	every 15.minutes do
	rake "redmine_update_reminder:send_reminders"
	end 

This will check for all issues that have not been updated in the specified duration from current time and send them an email. 
These issues will be checked every 15 minutes and will be sent emails till they are updated. 

Check whenever gems documentation for detailed description of its working.




