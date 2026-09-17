require 'rails_helper'

RSpec.describe SponsorLogoRestore do
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:png_bytes) { "\x89PNG\r\n\x1a\nfake-image-body".dup.force_encoding('ASCII-8BIT') }
  let(:html_bytes) { '<!DOCTYPE html><html><body>Wayback is degraded</body></html>'.dup.force_encoding('ASCII-8BIT') }
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
    "#{AWS_ASSETS.fetch(:bucket)}.s3.#{AWS_ASSETS.fetch(:region)}.amazonaws.com"
  end

  def head_stub(path, *responses)
    stub_request(:head, "https://#{bucket_host}#{path}").to_return(*responses)
  end

  def call
    described_class.call(s3_client:, delay: 0, retry_delay: 0, cdx_retry_delay: 0)
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SPONSORS_URL').and_return(nil)
    stub_request(:get, 'https://codebar.io/sponsors').to_return(body: page_html)
    head_stub('/uploads/sponsor/1/exists.png', status: 200)
    head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
    head_stub('/uploads/sponsor/3/gone.png', status: 404)
    stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: cdx_body)
  end

  describe '#content_type' do
    it 'maps filename extensions to MIME types' do
      service = described_class.new

      expect(service.send(:content_type, 'logo.png')).to eq('image/png')
      expect(service.send(:content_type, 'logo.jpg')).to eq('image/jpeg')
      expect(service.send(:content_type, 'logo.jpeg')).to eq('image/jpeg')
      expect(service.send(:content_type, 'logo.gif')).to eq('image/gif')
      expect(service.send(:content_type, 'logo.svg')).to eq('image/svg+xml')
      expect(service.send(:content_type, 'logo.webp')).to eq('application/octet-stream')
    end
  end

  describe 'politeness pacing' do
    it 'sleeps the politeness delay before each download and the retry delay between attempts' do
      instance = described_class.new(s3_client:, delay: 3, retry_delay: 7)
      allow(instance).to receive(:sleep)
      stub_request(:get, wayback_download_url).to_return({ status: 500 }, { status: 200, body: png_bytes })
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      instance.call('https://codebar.io/sponsors')

      expect(instance).to have_received(:sleep).with(3).twice
      expect(instance).to have_received(:sleep).with(7).once
    end

    it 'sleeps the Retry-After interval after a 429 response' do
      instance = described_class.new(s3_client:, delay: 3, retry_delay: 7)
      allow(instance).to receive(:sleep)
      stub_request(:get, wayback_download_url).to_return(status: 429, headers: { 'Retry-After' => '5' })
      allow(s3_client).to receive(:put_object)

      instance.call('https://codebar.io/sponsors')

      expect(instance).to have_received(:sleep).with(3).exactly(3).times
      expect(instance).to have_received(:sleep).with(5).exactly(2).times
    end
  end

  describe '.call' do
    it 'restores missing logos found in the Wayback Machine and reports the outcome' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object).with(
        bucket: AWS_ASSETS.fetch(:bucket),
        key: 'uploads/sponsor/2/missing logo.png',
        body: png_bytes,
        content_type: 'image/png',
        acl: 'public-read'
      )

      result = call

      expect(result.restored.map { |l| l[:sponsor_id] }).to eq([2])
      expect(result.skipped).to eq(1)
      expect(result.failed.map { |f| f[:sponsor_id] }).to eq([3])
      expect(result.failed.first[:reason]).to eq('not found in Wayback Machine index')
      expect(s3_client).to have_received(:put_object)
    end

    it 'is idempotent: logos already present are skipped and no archive lookups happen' do
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 200)
      head_stub('/uploads/sponsor/3/gone.png', status: 200)

      result = call

      expect(result.skipped).to eq(3)
      expect(result.restored).to be_empty
      expect(result.failed).to be_empty
      expect(a_request(:get, %r{web\.archive\.org/cdx})).not_to have_been_made
    end

    it 'retries transient archive downloads before giving up' do
      stub_request(:get, wayback_download_url).to_return({ status: 500 }, { status: 200, body: png_bytes })
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.restored.size).to eq(1)
      expect(a_request(:get, wayback_download_url)).to have_been_made.twice
    end

    it 'gives up immediately on a permanent 404 download instead of retrying' do
      stub_request(:get, wayback_download_url).to_return(status: 404)
      allow(s3_client).to receive(:put_object)

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('archive download failed')
      expect(a_request(:get, wayback_download_url)).to have_been_made.once
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'retries a rate-limited download honouring Retry-After' do
      stub_request(:get, wayback_download_url)
        .to_return(status: 429, headers: { 'Retry-After' => '0' })
      allow(s3_client).to receive(:put_object)

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('archive download failed')
      expect(a_request(:get, wayback_download_url)).to have_been_made.times(3)
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'rejects a 200 HTML error page as a failed download instead of uploading it' do
      stub_request(:get, wayback_download_url).to_return(status: 200, body: html_bytes)
      allow(s3_client).to receive(:put_object)

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('archive download failed')
      expect(a_request(:get, wayback_download_url)).to have_been_made.times(3)
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'records an availability-check failure instead of crashing when a HEAD probe raises' do
      head_stub('/uploads/sponsor/2/missing%20logo.png').to_raise(Errno::ECONNRESET)
      allow(s3_client).to receive(:put_object)

      result = call

      failed_logo = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed_logo[:reason]).to start_with('availability check failed')
      expect(result.failed.map { |f| f[:sponsor_id] }).to include(3)
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'records every missing logo as failed when the CDX index is unreachable' do
      stub_request(:get, %r{web\.archive\.org/cdx}).to_return(status: 500)
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.failed.map { |f| f[:sponsor_id] }).to contain_exactly(2, 3)
      expect(result.failed.map { |f| f[:reason] }.uniq.first).to start_with('Wayback CDX index unavailable')
      expect(a_request(:get, %r{web\.archive\.org/cdx})).to have_been_made.times(3)
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'does not mistake a CDX 200 HTML error page for an empty index' do
      stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: html_bytes)
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.failed.map { |f| f[:sponsor_id] }).to contain_exactly(2, 3)
      expect(result.failed.map { |f| f[:reason] }.uniq.first).to start_with('Wayback CDX index unavailable')
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'accepts an SVG-markup body as a restorable image' do
      svg = '<svg xmlns="http://www.w3.org/2000/svg"><rect/></svg>'
      stub_request(:get, wayback_download_url).to_return(body: svg)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.restored.size).to eq(1)
      expect(s3_client).to have_received(:put_object)
    end

    it 'restores only the first N missing logos when a limit is set' do
      allow(ENV).to receive(:[]).with('RESTORE_LIMIT').and_return('1')
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.restored.map { |l| l[:sponsor_id] }).to eq([2])
      expect(result.deferred.map { |l| l[:sponsor_id] }).to eq([3])
      expect(result.skipped).to eq(1)
    end

    it 'rehearses downloads without uploading when dry run is set' do
      allow(ENV).to receive(:[]).with('DRY_RUN').and_return('1')
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.rehearsed.map { |l| l[:sponsor_id] }).to eq([2])
      expect(result.failed.map { |f| f[:sponsor_id] }).to eq([3])
      expect(result.skipped).to eq(1)
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'reports phase progress so long batches are not silent' do
      messages = []
      instance = described_class.new(s3_client:, delay: 0, retry_delay: 0, cdx_retry_delay: 0, progress: ->(m) { messages << m })
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      instance.call('https://codebar.io/sponsors')

      expect(messages).to include(a_string_matching(/Found 3 logo references/))
      expect(messages).to include(a_string_matching(%r{Availability check: 3/3}))
      expect(messages).to include(a_string_matching(/Fetching Wayback CDX index/))
      expect(messages).to include(a_string_matching(%r{Restore progress: 2/2}))
    end

    it 'retries a failed CDX fetch and reports it' do
      messages = []
      instance = described_class.new(s3_client:, delay: 0, retry_delay: 0, cdx_retry_delay: 0, progress: ->(m) { messages << m })
      allow(instance).to receive(:sleep)
      stub_request(:get, %r{web\.archive\.org/cdx}).to_return({ status: 500 }, { body: cdx_body })
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      instance.call('https://codebar.io/sponsors')

      expect(messages).to include(a_string_matching(/CDX fetch failed.*retrying/))
      # one sleep(0) for the CDX backoff, one for the download's politeness tick
      expect(instance).to have_received(:sleep).with(0).twice
    end

    it 'sleeps for Retry-After when the CDX fetch is throttled' do
      messages = []
      instance = described_class.new(s3_client:, delay: 0, retry_delay: 0, cdx_retry_delay: 7, progress: ->(m) { messages << m })
      allow(instance).to receive(:sleep)
      stub_request(:get, %r{web\.archive\.org/cdx})
        .to_return({ status: 503, headers: { 'Retry-After' => '3' } }, { body: cdx_body })
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = instance.call('https://codebar.io/sponsors')

      expect(instance).to have_received(:sleep).with(3)
      expect(result.restored.size).to eq(1)
    end

    it 'prefers an intact capture over a newer error-page capture' do
      good_ts = '20230101000000'
      good_url = 'https://web.archive.org/web/20230101000000im_/http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png'
      stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: <<~CDX)
        io,codebar,assets)/b/uploads/sponsor/avatar/2/missing%20logo.png #{good_ts} http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png image/png 200 ABC 100
        io,codebar,assets)/b/uploads/sponsor/avatar/2/missing%20logo.png 20250617005043 http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png unk 522 ABC 809
      CDX
      stub_request(:get, good_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.restored.size).to eq(1)
      expect(a_request(:get, good_url)).to have_been_made.once
    end

    it 'falls back to the thumb variant when the original capture is an error page' do
      thumb_url = 'https://web.archive.org/web/20250215031600im_/http://assets.codebar.io/b//uploads/sponsor/avatar/4/thumb_photo.png'
      stub_request(:get, 'https://codebar.io/sponsors').to_return(body: page_html.sub(
        'uploads/sponsor/3/gone.png', 'uploads/sponsor/4/photo.png'
      ))
      head_stub('/uploads/sponsor/4/photo.png', { status: 403 }, { status: 200 })
      stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: <<~CDX)
        io,codebar,assets)/b/uploads/sponsor/avatar/4/photo.png 20250617005043 http://assets.codebar.io/b//uploads/sponsor/avatar/4/photo.png unk 522 ABC 809
        io,codebar,assets)/b/uploads/sponsor/avatar/4/thumb_photo.png 20250215031600 http://assets.codebar.io/b//uploads/sponsor/avatar/4/thumb_photo.png image/png 200 ABC 5000
      CDX
      stub_request(:get, thumb_url).to_return(body: png_bytes)
      allow(s3_client).to receive(:put_object).with(
        bucket: AWS_ASSETS.fetch(:bucket),
        key: 'uploads/sponsor/4/photo.png',
        body: png_bytes,
        content_type: 'image/png',
        acl: 'public-read'
      )

      result = call

      expect(result.restored.map { |l| l[:sponsor_id] }).to eq([4])
      expect(s3_client).to have_received(:put_object)
    end

    it 'accepts an ICO archive download and uploads it with the icon content type' do
      ico = "\x00\x00\x01\x00\x03\x00".dup.force_encoding('ASCII-8BIT')
      stub_request(:get, wayback_download_url).to_return(body: ico)
      head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
      allow(s3_client).to receive(:put_object)

      result = call

      expect(result.restored.size).to eq(1)
      expect(s3_client).to have_received(:put_object)
    end

    it 'records a mid-download network failure instead of crashing the batch' do
      stub_request(:get, wayback_download_url).to_raise(Errno::ECONNRESET)
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
      allow(s3_client).to receive(:put_object)

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to include('Connection reset')
      expect(result.restored).to be_empty
      expect(s3_client).not_to have_received(:put_object)
    end

    it 'reports logos that fail to verify after upload as failed' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
      allow(s3_client).to receive(:put_object)

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to eq('upload verification failed')
      expect(result.restored).to be_empty
    end

    it 'reports S3 upload errors as failed' do
      stub_request(:get, wayback_download_url).to_return(body: png_bytes)
      head_stub('/uploads/sponsor/2/missing%20logo.png', status: 403)
      allow(s3_client).to receive(:put_object).and_raise(Aws::S3::Errors::ServiceError.new(nil, 'boom'))

      result = call

      failed = result.failed.find { |f| f[:sponsor_id] == 2 }
      expect(failed[:reason]).to include('boom')
    end
  end
end
