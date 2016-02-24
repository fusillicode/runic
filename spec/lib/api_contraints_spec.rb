require 'rails_helper'

describe ApiConstraints do
  let(:api_version_header_base) { "application/#{Rails.application.class.parent_name}" }

  describe '#matches?' do
    context 'when the "default" option is specified' do
      let(:api_constraints) { ApiConstraints.new(version: 1, default: true) }

      it do
        request = double(host: 'localhost')
        expect(api_constraints.matches?(request)).to be true
      end
    end

    context 'when the "default" option is not specified' do
      let(:api_constraints) { ApiConstraints.new(version: 1) }

      context 'and the version matches the "Accept" header of the request' do
        let(:headers) { { 'Accept' => "#{api_version_header_base}.v1" } }

        it do
          request = double(host: 'localhost', headers: headers)
          expect(api_constraints.matches?(request)).to be true
        end
      end

      context 'and the version does not match the "Accept" header of the request' do
        let(:headers) { { 'Accept' => "#{api_version_header_base}.v2" } }

        it do
          request = double(host: 'localhost', headers: headers)
          expect(api_constraints.matches?(request)).to be false
        end
      end
    end
  end

  describe '#api_version_header' do
    let(:api_version) { 1 }
    let(:api_constraints) { ApiConstraints.new(version: api_version) }

    it do
      expect(api_constraints.api_version_header).to eq "#{api_version_header_base}.v#{api_version}"
    end
  end
end
