# frozen_string_literal: true

namespace :laravel do
  task :set_permission do
    on roles(:laravel) do
      execute :sudo, "chmod -R ug+rwx #{shared_path}/storage/ #{release_path}/bootstrap/cache/"
      execute :sudo, "chgrp -R www-data #{shared_path}/storage/ #{release_path}/bootstrap/cache/"
    end
  end
end
