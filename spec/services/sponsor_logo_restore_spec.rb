require 'rails_helper'

RSpec.describe SponsorLogoRestore do
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:png_bytes) { "\x89PNG\r\n\x1a\nfake-image-body".dup.force_encoding('ASCII-8BIT') }
  let(:page_html) do
    <<~HTML
      <html><body>
        <img class="small-image" src="https://#{bucket_host}/uploads/sponsor/1/exists.png">
        <img class="small-image" src="https://#{bucket_host}/uploads/sponsor/2/missing%20logo.png">
        <img class="small-image" src="https://#{bucket_host}/uploads/sponsor/3/gone.png">
        <img src="/assets/logo.png">
        <img>
      </body></html>
    HTML
  end
  let(:cdx_body) do
    <<~CDX
      io,codebar,assets)/b/uploads/sponsor/avatar/2/missing%20logo.png 20230203155648 http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png image/png 200 ABC 100
      io,codebar,assets)/b/uploads/sponsor/avatar/2/missing%20logo.png 20210101000000 http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png image/png 200 ABC 100
    CDX
  end
  let(:wayback_download_url) do
    'https://web.archive.org/web/20230203155648im_/http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png'
  end

  def bucket_host
    "#{ENV.fetch('S3_BUCKET_NAME', 'prod-sponsor-logos')}" \
      ".s3.#{ENV.fetch('AWS_REGION', 'eu-north-1')}.amazonaws.com"
  end

  def head_stub(path, *responses)
    stub_request(:head, "https://#{bucket_host}#{path}").to_return(*responses)
  end

  before do
    stub_request(:get, 'https://codebar.io/sponsors').to_return(body: page_html)
    head_stub('/uploads/sponsor/1/exists.png', status: 200)
    head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
    head_stub('/uploads/sponsor/3/gone.png', status: 404)
    stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: cdx_body)
  end

  describe '.call' do
    it 'restores missing logos found in the Wayback Machine and reports the outcome' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object).with(
        bucket: ENV.fetch('S3_BUCKET_NAME', 'prod-sponsor-logos'),
        key: 'uploads/sponsor/2/missing logo.png',
        body: png_bytes,
        content_type: 'image/png',
        acl: 'public-read'
      )

      result = described_class.call(s3_client:, delay: 0)

      expect(result.restored.map { |l| l[:sponsor_id] }).to eq([2])
      expect(result.skipped).to eq(1)
      expect(result.failed.map { |f| f[:sponsor_id] }).to eq([3])
      expect(result.failed.first[:reason]).to eq('not found in Wayback Machine index')
      expect(s3_client).to have_received(:put_object)
    end

    it 'is idempotent: logos already present are skipped and no archive lookups happen' do
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 200)
      head_stub('/uploads/sponsor/3/gone.png', status: 200)

      result = described_class.call(s3_client:, delay: 0)

      expect(result.skipped).to eq(3)
      expect(result.restored).to be_empty
      expect(result.failed).to be_empty
    end

    it 'retries failed archive downloads before giving up' do
      stub_request(:get, wayback_download_url).to_return({ status: 500 }, { status: 200, body: png_bytes })
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = described_class.call(s3_client:, delay: 0)

      expect(result.restored.size).to eq(1)
      expect(a_request(:get, wayback_download_url)).to have_been_made.twice
    end

    it 'reports logos whose archive copy cannot be downloaded as failed' do
      stub_request(:get, wayback_download_url).to_return(status: 404)
      allow(s3_client).to receive(:put_object)

      result = described_class.call(s3_client:, delay: 0)

      expect(result.restored).to be_empty
      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('archive download failed')
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'reports logos that fail to verify after upload as failed' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
      allow(s3_client).to receive(:put_object)

      result = described_class.call(s3_client:, delay: 0)

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('upload verification failed')
      expect(result.restored).to be_empty
    end

    it 'reports S3 upload errors as failed' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
      allow(s3_client).to receive(:put_object).and_raise(Aws::S3::Errors::ServiceError.new(nil, 'boom'))

      result = described_class.call(s3_client:, delay: 0)

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to include('boom')
    end
  end
end
