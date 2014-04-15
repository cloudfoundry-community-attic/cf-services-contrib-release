require "common/exec"
require "excon"

module ContribServices
  include Bosh::Exec

  def deploy_app(app_dir)
    app_path = File.join(File.dirname(__FILE__), "assets", app_dir)
    sh "cf push #{app_name} -p=#{app_path} --no-start"
  end

  def login
    puts "Running tests on #{target} on behalf of #{test_user}"
    sh "cf api #{target}"
    sh "cf auth #{test_user} #{test_pwd}"
  end

  def test_user
    ENV['VCAP_EMAIL'] || "admin"
  end

  def test_pwd
    ENV['VCAP_PWD'] || "admin"
  end

  def target
    ENV['VCAP_TARGET'] || "https://api.10.244.0.34.xip.io"
  end

  def organization
    ENV['VCAP_ORG'] || "services"
  end

  def space
    ENV['VCAP_SPACE'] || "contrib"
  end

  def domain_name
    target.split(".")[1..-1].join(".")
  end

  def app_name
    "services-contrib-test"
  end

  def app_url
    "http://#{app_name}.#{domain_name}"
  end

  def system_services
    @system_services ||= sh("cf marketplace").output
  end

  def service_available?(name)
    system_services.match(name)
  end

  def target_space
    create_space
    sh "cf target -o #{organization} -s #{space}"
  end

  def create_space
    if sh("cf space #{space}", on_error: :return).failed?
      sh("cf create-space #{space}")
    end
  end

  def delete_space
    unless sh("cf space #{space}", on_error: :return).failed?
      sh "cf delete-space #{space} -f"
    end
  end

  def start_app
    puts "Starting application (please wait)"
    sh "cf start #{app_name}"
  end

  def provision_service(service_type)
    return unless service_available?(service_type)
    service_name = "test-#{service_type}"
    delete_service(service_name)
    create_service(service_type, service_name)
    bind_service(service_name)
  end

  def create_service(service_type, service_name)
    sh "cf create-service #{service_type} default #{service_name}"
  end

  def delete_service(service_name)
    unless sh("cf service #{service_name}", on_error: :return).failed?
      unbind_service(app_name, service_name)
      sh "cf delete-service #{service_name} -f"
    end
  end

  def bind_service(service_name)
    sh "cf bind-service #{app_name} #{service_name}"
  end

  def unbind_service(app_name, service_name)
    sh "cf unbind-service #{app_name} #{service_name}", on_error: :return
  end
end

RSpec.configure do |config|
  config.include ContribServices
end
