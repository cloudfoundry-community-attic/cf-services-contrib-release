require 'sinatra'
require 'cf-app-utils'

require_relative 'services/postgresql'

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
