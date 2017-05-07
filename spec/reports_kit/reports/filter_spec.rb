require 'spec_helper'

describe ReportsKit::Reports::Filter do
  subject { described_class.new(properties, measure: measure) }
  let(:measure) { ReportsKit::Reports::Measure.new('issues') }

  context 'with a datetime filter' do
    let(:properties) { 'opened_at' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ column: 'issues.opened_at' })
    end
  end

  context 'with a belongs_to association filter' do
    let(:properties) { 'repo' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ column: 'issues.repo_id' })
    end
  end

  context 'with a has_many association filter' do
    let(:properties) { 'tags' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ joins: :tags, column: 'tags.id' })
    end
  end

  context 'with a has_many :through association filter' do
    let(:properties) { 'labels' }

    it 'returns the settings' do
      expect(subject.settings).to eq({ joins: :issues_labels, column: 'issues_labels.label_id' })
    end
  end
end
