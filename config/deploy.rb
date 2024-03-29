# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "awsTest"
set :repo_url, "git@github.com:praneenshakya/awsTest.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ubuntu/app"

append :linked_dirs,
       'storage/app',
       'storage/framework/cache',
       'storage/framework/sessions',
       'storage/framework/views',
       'storage/framework/testing',
       'storage/logs'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :app do
    desc 'Set environment variables'
    task :set_variables do
        on roles(:app) do
         puts '--> Copying environment configuration file'
         execute "cp #{release_path}/.env.server #{release_path}/.env"
         puts '--> Setting environment variables'
         execute "sed --in-place -f #{fetch(:overlay_path)}/parameters.sed #{release_path}/.env"
        end
    end
end

namespace :nginx do
    desc 'Reload nginx server'
    task :reload do
      on roles(:all) do
        execute :sudo, :systemctl, 'reload nginx'
      end
    end
end

namespace :fpm do
    desc 'Reload php-fpm server'
    task :reload do
      on roles(:all) do
        execute :sudo, :systemctl, 'reload php7.2-fpm'
      end
    end
end

namespace :deploy do
    after :updated, 'composer:vendor_copy'
    after :updated, 'composer:install'
    after :updated, 'laravel:set_permission'
    after :updated, 'app:set_variables'
end

after 'deploy',   'nginx:reload'
after 'deploy',   'fpm:reload'
