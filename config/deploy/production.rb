set :branch, 'production'

role :app, %w{deploy@registry.production.local}
role :db,  %w{deploy@registry-db.production.local}

# role :resque_worker, %w{deploy@registry.production.local}
# role :resque_scheduler, %w{deploy@registry.production.local}
