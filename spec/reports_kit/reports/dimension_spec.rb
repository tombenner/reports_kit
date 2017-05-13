require 'spec_helper'

describe ReportsKit::Reports::Dimension do
  subject { described_class.new(properties, measure: measure) }
  let(:measure) { ReportsKit::Reports::Measure.new('issue') }

  context 'with a datetime dimension' do
    let(:properties) { 'opened_at' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ column: 'issues.opened_at', group: "date_trunc('week', issues.opened_at::timestamp)" })
    end
  end

  context 'with a belongs_to association dimension' do
    let(:properties) { 'repo' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ column: 'issues.repo_id', group: 'issues.repo_id' })
    end
  end

  context 'with a has_many association dimension' do
    let(:properties) { 'tags' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ joins: :tags, column: 'tags.id', group: 'issues.issue_id' })
    end
  end

  context 'with a has_many :through association dimension' do
    let(:properties) { 'labels' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ joins: :issues_labels, column: 'issues_labels.label_id', group: 'issues.label_id' })
    end
  end
end
