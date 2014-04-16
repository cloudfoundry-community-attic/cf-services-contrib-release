require 'bunny'

post '/service/rabbitmq/:key' do
  value = request.env["rack.input"].read
  channel = load_rabbitmq
  queue = channel.queue(params[:key])
  channel.default_exchange.publish(value, routing_key: queue.name)
  value
end

get '/service/rabbitmq/:key' do
  channel = load_rabbitmq
  queue = channel.queue(params[:key])
  _, _, value = queue.pop
  value
end

def load_rabbitmq
  url = CF::App::Credentials.find_by_service_label('rabbitmq')['url']
  conn = Bunny.new(url)
  conn.start
  conn.create_channel
end
