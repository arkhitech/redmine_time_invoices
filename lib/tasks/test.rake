task :my => :environment do
  user=User.first
  puts user.name
end