source 'https://rubygems.org'

gem 'rails',        '4.1'
gem 'sass-rails', "~> 4.0.3"
gem 'json', '>= 1.8.3'
gem 'minitest', '5.8.1'
gem 'uuidtools', '>= 2.1.5'
gem 'simplecov', '>= 0.9.0'

# Removed all test gems because some of them have a dependency on ffi
# and I cannot get that building. I don't use any of these yet anyway
# so it serves me right.

group :test do
  #gem 'rspec'
  #gem 'shoulda-matchers'
  #gem 'capybara', '>= 2.4.4'
  #gem 'selenium-webdriver', '>= 2.43.0'
  #gem 'faker'
  #gem 'autotest-standalone'
  #gem 'autotest-growl'
  #gem 'approvals', '>= 0.0.7'
  #gem 'cucumber'
end

# rspec-rails needs to be in the development group so that Rails generators work.
group :development, :test do
  #gem 'rspec-rails'
end
