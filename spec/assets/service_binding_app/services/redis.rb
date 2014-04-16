require 'redis'

get '/service/redis/:key' do
  load_redis[params[:key]]
end

post '/service/redis/:key' do
  load_redis[params[:key]] = request.env["rack.input"].read
end

def load_redis
  c = OpenStruct.new(CF::App::Credentials.find_by_service_label('redis'))
  Redis.new(host: c.host, port: c.port, password: c.password, db: c.name)
end
