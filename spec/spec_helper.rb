ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require File.expand_path '../../mrpostman.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods

  def json_body
    JSON.parse(subject.body)
  end

  def app() Mrpostman end
end

RSpec.configure do |config|
  config.include RSpecMixin
end
