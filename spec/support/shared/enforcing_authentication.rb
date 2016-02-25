shared_examples 'render unauthorized' do
  before { action }
  it { expect(response).to be_unauthorized }
  it { expect(response).to match_response_schema 'unauthorized' }
end
