require_relative './serverspec_helpers'

host_url = 'hello_world.clinker.io'

describe "hello_wolrd app" do
  describe host(host_url) do
    # ping
    it { should be_reachable }
    # set protocol explicitly
    it { should be_reachable.with( :port => 8090, :proto => 'tcp' ) }
  end


  it 'shoudl' do
    ok(false)
  end
end

