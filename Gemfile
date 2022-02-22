# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'archivesspace-client'
gem 'mechanize'
gem 'rake'
gem 'thor'
gem 'selenium-webdriver'
gem 'webdrivers', '~> 5.0'

group :development do
  gem "capistrano", "~> 3.16"
  gem "capistrano-bundler"
  gem "pry-byebug"
end

group :test, :development do
  gem 'rspec'
  gem 'rubocop'
end
