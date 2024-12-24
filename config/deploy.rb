lock "~> 3.19.1"
set :application, "medical_insurance"
set :shared_path, "/home/ubuntu/deploy/medical_insurance/shared"
set :current_path, "/home/ubuntu/deploy/medical_insurance/current"
set :repo_path, "/home/ubuntu/deploy/medical_insurance/repo"
set :repo_url, "git@github.com:adnan5043/medical-insurance.git"
set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"
set :deploy_to, "/home/ubuntu/deploy/#{fetch :application}"
set :deploy_via, :copy
set :rbenv1_map_bins, %w(rake gem bundle ruby honeybadger)
set :ssh_options, { forward_agent: true, user: "root", auth_methods: ['publickey']}
on roles(:all) do
  execute :sudo, :mkdir, "-p", "/home/ubuntu/deploy/medical_insurance/shared /home/ubuntu/deploy/medical_insurance/releases"
end

append :linked_files, 'config/master.key'

before 'deploy:updated', :updated_cache do
  append :linked_files, 'config/credentials/production.key', 'config/master.key'
end
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage", 'vendor/bundle', '.bundle', 'public/uploads'

set :rbenv_ruby_version, 'ruby-3.2.0'
set :rbenv_type, :user # or :system, depending on your setup
set :rbenv_ruby, '3.2.0'

set :keep_releases, 3
# set :conditionally_migrate, true

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
 
  desc 'Upload master.key'
  task :upload_master_key do
    on roles(:app) do
      unless test("[ -f #{shared_path}/config/master.key ]")
        upload! 'config/master.key', "#{shared_path}/config/master.key"
      end
    end
  end

  before 'deploy:check:linked_dirs', 'deploy:upload_master_key'
  after 'deploy:publishing', 'passenger:restart'

end


