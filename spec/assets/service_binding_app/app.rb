require 'sinatra'
require 'cf-app-utils'

%w(postgresql mongodb redis).each do |service|
  require_relative "services/#{service}"
end

get '/env' do
  ENV['VCAP_SERVICES']
end

get '/' do
  'hello from sinatra'
end

error do
  env['sinatra.error'].to_s
end

not_found do
  'This is nowhere to be found.'
end
