role :app, %w{deploy@registry.production.local}
role :db,  %w{deploy@registry-db.production.local}

set :branch, 'production'
