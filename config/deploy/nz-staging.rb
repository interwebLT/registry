role :app, %w{deploy@nz-registry.production.local}
role :db,  %w{deploy@nz-registry-db.production.local}

set :branch, 'nz-api'
