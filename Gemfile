source "https://rubygems.org"

gem "rails", "~> 7.2.3"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# Rails 7.2 passes :quirks_mode to JSON.generate, removed in json 3.x.
gem "json", "~> 2.7"

# Serialization
gem "active_model_serializers", "~> 0.10.14"

# Domain / multi-tenancy / auth
gem "acts_as_tenant", "~> 2.0"
gem "devise", "~> 4.9"
gem "devise-jwt"
gem "pundit"
gem "ruby_llm"
gem "paranoia"
gem "paper_trail"
gem "phonelib"
gem "devise_invitable"

# Query / pagination / counters
gem "ransack", "~> 4.2"
gem "kaminari-activerecord", "~> 1.2"
gem "counter_culture", "~> 3.2"

# Background / cache / cable
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"

# Config / tooling
gem "dotenv-rails"
gem "pghero"
gem "pdf-reader", "~> 2.13"
gem "rack-cors"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "bullet"
  gem "letter_opener"
  gem "web-console"
end

group :test do
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end
