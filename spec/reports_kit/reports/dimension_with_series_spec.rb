require 'spec_helper'

describe ReportsKit::Reports::DimensionWithSeries do
  subject { described_class.new(dimension: dimension, series: series) }
  let(:dimension) { ReportsKit::Reports::Dimension.new(properties) }
  let(:series) { ReportsKit::Reports::Series.new(measure: 'issue', dimensions: [properties]) }

  describe 'settings' do
    context 'with a datetime dimension' do
      let(:properties) { 'opened_at' }

      it 'returns the settings' do
        expect(subject.settings).to eq({ column: 'issues.opened_at', group: database_adapter.truncate_to_week('issues.opened_at') })
      end
    end

    context 'with a string dimension' do
      let(:properties) { 'title' }

      it 'returns the settings' do
        expect(subject.settings).to eq({ column: 'issues.title', group: 'issues.title' })
      end
    end

    context 'with a text dimension' do
      let(:properties) { 'description' }

      it 'returns the settings' do
        expect(subject.settings).to eq({ column: 'issues.description', group: 'issues.description' })
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
        expect(subject.settings).to eq({ joins: :issues_labels, column: 'issues_labels.label_id', group: 'issues_labels.label_id' })
      end
    end

    describe ':key_to_label setting' do
      context 'with a Proc' do
        let(:properties) { 'titleized_state' }

        it 'returns the result of the Proc' do
          expect(subject.key_to_label('foo')).to eq('Foo')
        end
      end
    end
  end
end
