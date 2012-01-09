# Your HTTP server, Apache/etc
role :web, 'qaserver.intersect.org.au'
# This may be the same as your Web server
role :app, 'qaserver.intersect.org.au'
# This is where Rails migrations will run
role :db,  'qaserver.intersect.org.au'

