require 'pg'

post '/service/postgresql/:key' do
  client = load_postgresql
  key = params[:key]
  value = request.env["rack.input"].read
  sql = "insert into data (id, value) values('#{key}','#{value}');"
  client.query sql
  client.close
  value
end

get '/service/postgresql/:key' do
  client = load_postgresql
  sql = "select value from data where id = '#{params[:key]}'"
  value = client.query(sql).first['value']
  client.close
  value
end

def load_postgresql
  c = OpenStruct.new(CF::App::Credentials.find_by_service_label('postgresql'))
  client = PG.connect(host: c.host,
                      port: c.port,
                      user: c.user,
                      password: c.password,
                      dbname: c.name)

  sql = "select * from information_schema.tables where table_name = 'data';"
  if client.query(sql).first.nil?
    client.query("create table data (id varchar(20), value varchar(20));")
  end
  client
end
