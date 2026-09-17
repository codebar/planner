require 'rails_helper'
require 'fileutils'

RSpec.describe SponsorLogoRestore do
  let(:s3_client) { instance_double(Aws::S3::Client) }
  let(:png_bytes) { "\x89PNG\r\n\x1a\nfake-image-body".dup.force_encoding('ASCII-8BIT') }
  let(:page_html) do
    <<~HTML
      <html><body>
        <img class="small-image" src="https://#{bucket_host}/uploads/sponsor/1/exists.png">
        <img class="small-image" src="https://#{bucket_host}/uploads/sponsor/2/missing%20logo.png">
      </body></html>
    HTML
  end
  let(:cdx_body) do
    <<~CDX
      io,codebar,assets)/b/uploads/sponsor/avatar/2/missing%20logo.png 20230203155648 http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png image/png 200 ABC 100
    CDX
  end
  let(:wayback_download_url) do
    'https://web.archive.org/web/20230203155648im_/http://assets.codebar.io/b//uploads/sponsor/avatar/2/missing%20logo.png'
  end

  let(:cache_root) { Dir.mktmpdir }

  def bucket_host
    "#{AWS_ASSETS.fetch(:bucket)}.s3.#{AWS_ASSETS.fetch(:region)}.amazonaws.com"
  end

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('SPONSORS_URL').and_return(nil)
    allow(ENV).to receive(:[]).with('SPONSOR_LOGO_CACHE').and_return('1')
    allow(Rails).to receive(:root).and_return(Pathname.new(cache_root))
    stub_request(:get, 'https://codebar.io/sponsors').to_return(body: page_html)
    head_stub('/uploads/sponsor/1/exists.png', status: 200)
    head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
    stub_request(:get, %r{web\.archive\.org/cdx}).to_return(body: cdx_body)
  end

  after do
    FileUtils.remove_entry(cache_root)
  end

  def head_stub(path, *responses)
    stub_request(:head, "https://#{bucket_host}#{path}").to_return(*responses)
  end

  def new_run
    SponsorLogoRestore.new(s3_client:, delay: 0, retry_delay: 0, progress: ->(_) { })
  end

  it 'reuses cached availability and CDX results on the second run' do
    allow(s3_client).to receive(:put_object)
    stub_request(:get, wayback_download_url).to_return(body: png_bytes)

    new_run.call('https://codebar.io/sponsors')
    new_run.call('https://codebar.io/sponsors')

    # exists.png: 1 classification HEAD (cached in run 2). missing logo:
    # run 1 classification HEAD + live verification HEAD, whose 200 result is
    # then cached — so run 2 classifies the logo present without probing or
    # re-restoring it.
    expect(a_request(:head, /#{bucket_host}/)).to have_been_made.times(3)
    expect(a_request(:get, %r{web\.archive\.org/cdx})).to have_been_made.once
    expect(a_request(:get, wayback_download_url)).to have_been_made.once
  end

  it 'keeps verify-after-upload checks live even for cached URLs' do
    stub_request(:get, wayback_download_url).to_return(body: png_bytes)
    head_stub('/uploads/sponsor/2/missing%20logo.png', { status: 403 }, { status: 200 })
    allow(s3_client).to receive(:put_object)

    result = new_run.call('https://codebar.io/sponsors')

    expect(result.restored.size).to eq(1)
    # classification HEAD (403) + post-upload verification HEAD (200)
    expect(a_request(:head, /missing%20logo/)).to have_been_made.twice
  end

  it 'expires entries after the configured TTL' do
    instance = new_run
    instance.cache_write('some-key', 'some-value')
    expect(instance.cache_read('some-key')).to eq('some-value')

    allow(Time).to receive(:now).and_return(Time.zone.now + 7.hours)
    expect(instance.cache_read('some-key')).to be_nil
  end

  it 'ignores cached values while REFRESH_CACHE is set' do
    instance = new_run
    instance.cache_write('some-key', 'some-value')
    allow(ENV).to receive(:[]).with('REFRESH_CACHE').and_return('1')

    expect(instance.cache_read('some-key')).to be_nil
  end
end
