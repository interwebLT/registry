set :application, 'registry'
set :repo_url, 'https://github.com/dotph/registry.git'
set :branch, ENV['REVISION'] || ENV['BRANCH'] || proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :rails_env, 'production'

set :deploy_to, '/srv/registry'
set :log_level, :info
set :linked_files, %w{config/secrets.yml config/database.yml config/exception_notification.yml config/checkout.yml config/sidekiq.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :default_env, { path: "$PATH:/usr/pgsql-9.3/bin" }

set :rbenv_type, :user
set :rbenv_ruby, proc { `cat .ruby-version`.chomp }.call
set :rbenv_map_bins, %w{rake gem bundle ruby rails unicorn}

set :bundle_jobs, 4
set :bundle_env_variables, { nokogiri_use_system_libraries: 1 }

set :sidekiq_queue, 'sync_registry_changes'
set :sidekiq_concurrency, 5

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  task :restart do
    on roles :all do
      execute "/etc/init.d/unicorn upgrade"
    end
  end
end

set :whenever_roles, ->{ :app }

# after 'deploy:updated',     'whenever:update_crontab'
# after 'deploy:reverted',    'whenever:update_crontab'
