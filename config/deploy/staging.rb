role :app, %w{deploy@registry.staging.local}
role :db,  %w{deploy@registry-db.staging.local}

role :resque_worker, %w{deploy@registry.staging.local}
role :resque_scheduler, %w{deploy@registry.staging.local}
