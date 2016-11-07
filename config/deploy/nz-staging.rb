role :app, %w{deploy@nz-registry.staging.local}
role :db,  %w{deploy@nz-registry-db.staging.local}

set :branch, 'nz-api'
