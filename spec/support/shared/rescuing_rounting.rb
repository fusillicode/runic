shared_examples 'render not found' do
  before { action }
  it { expect(response).to be_not_found }
  it { expect(response).to match_response_schema 'not_found' }
end

shared_examples 'render forbidden' do
  before { action }
  it { expect(response).to be_forbidden }
  it { expect(response).to match_response_schema 'forbidden' }
end

shared_examples 'render bad request' do
  before { action }
  it { expect(response).to bad_request }
  it { expect(response).to match_response_schema 'bad_request' }
end
