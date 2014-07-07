describe "service life cycles" do
  SERVICES = %w(postgresql mongodb redis rabbitmq)

  let(:key) { SecureRandom.hex(5) }
  let(:value) { SecureRandom.hex(5) }

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

      url = "#{app_url}/service/#{service}/#{key}"
      expect(Excon.post(url, body: value).body).to eq value
      expect(Excon.get(url).body).to eq value
    end

    after do
      delete_service(service)
    end
  end

  after(:all) do
  #  delete_space
  end
end
