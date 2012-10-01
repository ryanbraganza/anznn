# Your HTTP server, Apache/etc
set :web_server, 'anznn.med.unsw.edu.au'
# This may be the same as your Web server
set :app_server, 'anznn.med.unsw.edu.au'
# This is where Rails migrations will run
set :db_server, 'anznn.med.unsw.edu.au'
# The user configured to run the rails app
set :user, 'anznn'

role :web, web_server
role :app, app_server
role :db,  db_server, :primary => true

set :el6, false
set :proxy, nil
