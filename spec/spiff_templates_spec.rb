describe "Spiff templates" do
  let(:stubs) { nil }
  let(:uuid) { SecureRandom.uuid }

  subject { make_manifest(infra, stubs) }

  context "warden" do
    let(:infra) { "warden" }

    it "generates manifest" do
      subject
    end
  end

  context "openstack neutron" do
    let(:infra) { "openstack-neutron" }
    let(:stubs) do
      File.expand_path("../../examples/openstack-neutron-stub.yml", __FILE__)
    end

    it "generates manifest" do
      subject
    end
  end

  def make_manifest(infra, stubs)
    cmd = File.expand_path("../../templates/make_manifest", __FILE__)
    sh "DIRECTOR_UUID='#{uuid}' #{cmd} #{infra} #{Array(stubs).join(' ')}"
  end
end
