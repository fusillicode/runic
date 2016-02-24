shared_examples 'render_not_found' do
  before { action }
  it { expect(response).to be_not_found }
  it { expect(response).to match_response_schema 'not_found' }
end

shared_examples 'render_forbidden' do
  before { action }
  it { expect(response).to be_forbidden }
  it { expect(response).to match_response_schema 'forbidden' }
end

shared_examples 'render_bad_request' do
  before { action }
  it { expect(response).to bad_request }
  it { expect(response).to match_response_schema 'bad_request' }
end
