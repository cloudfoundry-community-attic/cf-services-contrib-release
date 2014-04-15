require 'mongo'

post '/service/mongodb/:key' do
  coll = load_mongo
  value = request.env["rack.input"].read
  coll.insert( { '_id' => params[:key], 'value' => value } )
  value
end

get '/service/mongodb/:key' do
  coll = load_mongo
  coll.find('_id' => params[:key]).to_a.first['value']
end

def load_mongo
  uri = CF::App::Credentials.find_by_service_label('mongodb')['url']
  db = Mongo::MongoClient.from_uri(uri).db
  db['data']
end
