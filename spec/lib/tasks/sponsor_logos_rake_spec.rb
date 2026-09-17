require 'rails_helper'

RSpec.describe 'rake sponsor_logos:restore', type: :task do
  let(:result) { SponsorLogoRestore::Result.new(restored:, skipped: 219, failed:) }
  let(:restored) { [{ sponsor_id: 2, filename: 'logo.png' }] }
  let(:failed) { [] }

  before do
    allow(SponsorLogoRestore).to receive(:call).and_return(result)
    task.reenable
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'restores logos and prints the summary' do
    expect { task.invoke }
      .to output(/Checked: 220 logos\nSkipped \(already present\): 219\nRestored: 1/).to_stdout

    expect(SponsorLogoRestore).to have_received(:call)
  end

  context 'when some logos could not be restored' do
    let(:failed) { [{ sponsor_id: 42, filename: 'broken.png', reason: 'archive download failed' }] }

    it 'lists the failures and aborts with a non-zero status' do
      expect { task.invoke }
        .to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }
        .and output(/FAILED sponsor 42 broken.png: archive download failed/).to_stdout
    end
  end
end
