require 'mongoid'

env = ENV['RACK_ENV'] || 'development'

puts "Environment: #{env}"

Mongoid.load!(File.dirname(__FILE__) + '/mongoid.yml', env)

class Topic
  include Mongoid::Document

  field :name, type: String # Displayed to user
  field :title, type: String  # Wikipedia article title
  field :url, type: String # Wikipedia article URL
  field :description, type: String # Wikipedia short description
end
