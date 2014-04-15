describe "service life cycles" do
  SERVICES = %w(postgresql)

  let(:app_api) { @app_api ||= Excon.new(app_url) }
  let(:value) { "bar" }

  before(:all) do
    login
    target_space
    deploy_app("service_binding_app")
    SERVICES.each { |service_name| provision_service(service_name) }
    start_app
  end

  SERVICES.each do |service|
    it "provisions #{service}" do
      pending "#{service}: not available" unless service_available?(service)

      path = "service/#{service}/foo"
      expect(app_api.post(path: path, body: value).body).to eq value
      expect(app_api.get(path: path).body).to eq value
    end
  end

  after(:all) do
    delete_space
  end
end
