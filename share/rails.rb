gem_group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

gem_group :development do
  gem 'guard-rspec'
  gem 'haml-rails'
end

gem_group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'shoulda-matchers'
end

gem_group :assets do
  gem 'bourbon'
  gem 'neat'
end

gem 'devise'
gem 'yard-rails', require: false
gem 'haml'
gem 'draper'
gem 'kaminari'
gem 'simple_form'

# Rspec support files
create_file 'spec/support/factory_girl.rb', <<-EOS
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
EOS

create_file 'spec/support/database_cleaner.rb', <<-EOS
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
EOS

create_file 'spec/support/devise.rb', <<-EOS
RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end
EOS

inject_into_file 'config/environments/test.rb', before: /^end$/ do
  "\n  config.action_mailer.default_url_options = { host: 'test.host' }\n"
end

inject_into_file 'config/environments/development.rb', before: /^end$/ do
  "\n  config.action_mailer.default_url_options = { host: 'localhost:3000' }\n"
end

inject_into_file 'config/environments/production.rb', before: /^end$/ do
  "\n  config.action_mailer.default_url_options = { host: 'change-me.com' }\n"
end

inject_into_file 'config/application.rb', after: 'config.assets.enabled = true' do
  "\n    config.assets.initialize_on_precompile = false\n"
end

route 'root to: "sessions#new"'

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
  g.template_engine     :haml
  g.test_framework      :rspec, fixture: true, fixture_replacement: :factory_girl
  g.view_specs          false
  g.helper_specs        false
  g.helper              false
  g.javascripts         false
  g.stylesheets         false
  g.fixture_replacement :factory_girl
  g.assets              false
end
RUBY

create_file 'app/decorators/ApplicationDecorator', <<-RUBY
class ApplicationDecorator < Draper::Base
end
RUBY

remove_file 'README.rdoc'
remove_file 'doc/README_FOR_APP'
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'

role = ask('What role should be used for the database configuration?')
run 'cp config/database.yml config/database.yml.example'
gsub_file 'config/database.yml', /  username: .+$/, "  username: #{role}"
gsub_file 'config/database.yml', /  pool: 5$/, "  pool: 5\n  host: localhost"
append_to_file '.gitignore', 'config/database.yml'

run 'bundle install'
run 'bundle update'

rake 'db:create'

generate 'rspec:install'
append_to_file '.rspec', '--order rand'
generate 'devise:install'
generate 'devise user'
generate 'simple_form:install'
generate 'kaminari:config'
run 'bundle exec guard init'

rake 'db:migrate'
rake 'db:test:prepare'

# git :init
# git add: '.'
# git commit: '-aqm "Initial commit of new Rails app"'
