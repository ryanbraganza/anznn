# Your HTTP server, Apache/etc
role :web, 'stagingserver.intersect.org.au'
# This may be the same as your Web server
role :app, 'stagingserver.intersect.org.au'
# This is where Rails migrations will run
role :db,  'stagingserver.intersect.org.au'

