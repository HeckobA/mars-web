require 'rspec'
require 'mongoid'

ENV['RACK_ENV'] = 'test'

require './models'

RSpec.configure do |config|
  #Other config stuff goes here

  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.purge!
  end
end
