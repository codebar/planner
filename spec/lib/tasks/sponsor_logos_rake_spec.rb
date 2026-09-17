require 'rails_helper'

RSpec.describe 'rake sponsor_logos:restore', type: :task do
  let(:result) do
    SponsorLogoRestore::Result.new(restored:, skipped:, failed:, rehearsed:, deferred:)
  end
  let(:restored) { [{ sponsor_id: 2, filename: 'logo.png' }] }
  let(:failed) { [] }
  let(:rehearsed) { [] }
  let(:deferred) { [] }
  let(:skipped) { 219 }

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

  context 'when a limit deferred part of the batch' do
    let(:deferred) do
      [{ sponsor_id: 7, filename: 'later.png' }, { sponsor_id: 8, filename: 'much-later.png' }]
    end

    it 'reports the deferred remainder as a summary line and exits cleanly' do
      expect { task.invoke }.to output(/Deferred \(limit\): 2/).to_stdout
    end
  end

  context 'with DRY_RUN set' do
    let(:rehearsed) { [{ sponsor_id: 2, filename: 'logo.png' }] }
    let(:restored) { [] }
    let(:skipped) { 0 }

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DRY_RUN').and_return('1')
    end

    it 'announces the dry run and reports the rehearsed count' do
      expect { task.invoke }
        .to output(/Dry run: nothing will be uploaded.*Rehearsed \(dry run\): 1.*Restored: 0/m).to_stdout
    end
  end
end
