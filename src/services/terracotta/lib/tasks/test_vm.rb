ROOT = File.expand_path("../../..", __FILE__)
GIT_URL = "git://github.com/cloudfoundry/warden-test-infrastructure.git"
REPO_PATH = "#{ROOT}/tmp/warden-test-infrastructure"
BOX_PATH = File.expand_path("~/boxes/ci_with_warden_prereqs.box")

desc "Check if configuration file is valid"
task :test_vm do
  if File.exists?(BOX_PATH)
    puts "Base test VM already exists. Skipping creation."
    next
  end

  sh "git clone #{GIT_URL} #{REPO_PATH}"
  Dir.chdir(REPO_PATH) do
    sh "git submodule update --init"
    sh "./create_vagrant_box.sh"
  end

  puts "Created base test VM at: #{BOX_PATH}"
end
