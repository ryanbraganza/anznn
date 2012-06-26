# Your HTTP server, Apache/etc
set :web_server, 'gsw1-anznn-qa.intersect.org.au'
# This may be the same as your Web server
set :app_server, 'gsw1-anznn-qa.intersect.org.au'
# This is where Rails migrations will run
set :db_server,  'gsw1-anznn-qa.intersect.org.au'
# The user configured to run the rails app


role :web, web_server
role :app, app_server
role :db,  db_server, :primary => true