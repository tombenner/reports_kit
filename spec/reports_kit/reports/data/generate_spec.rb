require 'spec_helper'

describe ReportsKit::Reports::Data::Generate do
  subject { described_class.new(properties, context_record: context_record).perform }

  let(:repo) { create(:repo) }
  let(:repo2) { create(:repo) }
  let(:context_record) { nil }
  let(:chart_data) { subject[:chart_data] }
  let(:chart_values) { chart_data.map { |series| series[:values] } }

  context 'with a datetime dimension' do
    let(:properties) do
      {
        measure: 'issues',
        dimensions: %w(opened_at)
      }
    end
    let!(:issues) do
      [
        create(:issue, repo: repo, opened_at: now - 2.weeks),
        create(:issue, repo: repo, opened_at: now - 2.weeks),
        create(:issue, repo: repo, opened_at: now)
      ]
    end

    it 'returns the chart_values' do
      expect(chart_values).to eq([[
        { x: week_offset_timestamp(2), y: 2 },
        { x: week_offset_timestamp(1), y: 0 },
        { x: week_offset_timestamp(0), y: 1 }
      ]])
    end

    context 'with a datetime filter' do
      let(:properties) do
        {
          measure: {
            key: 'issues',
            filters: [
              {
                key: 'opened_at',
                criteria: {
                  operator: 'between',
                  value: "#{date_string_for_filter(now - 1.week)} - #{date_string_for_filter(now)}"
                }
              }
            ]
          },
          dimensions: %w(opened_at)
        }
      end

      it 'returns the chart_values' do
        expect(chart_values).to eq([[
          { x: week_offset_timestamp(0), y: 1 }
        ]])
      end
    end
  end

  context 'with an association dimension' do
    let(:properties) do
      {
        measure: 'issues',
        dimensions: %w(repo)
      }
    end
    let!(:issues) do
      [
        create(:issue, repo: repo),
        create(:issue, repo: repo),
        create(:issue, repo: repo2)
      ]
    end

    it 'returns the chart_values' do
      expect(chart_values).to eq([[
        { x: repo.full_name, y: 2 },
        { x: repo2.full_name, y: 1 }
      ]])
    end

    context 'with a context_record' do
      let(:context_record) { repo }

      it 'returns the chart_values' do
        expect(chart_values).to eq([[
          { x: repo.full_name, y: 2 }
        ]])
      end
    end

    context 'with a belongs_to association filter' do
      let(:properties) do
        {
          measure: {
            key: 'issues',
            filters: [
              {
                key: 'repo',
                criteria: {
                  operator: 'include',
                  value: [repo.id]
                }
              }
            ]
          },
          dimensions: %w(repo)
        }
      end

      it 'returns the chart_values' do
        expect(chart_values).to eq([[
          { x: repo.full_name, y: 2 }
        ]])
      end
    end

    context 'with a has_many association filter' do
      let(:properties) do
        {
          measure: {
            key: 'issues',
            filters: [
              {
                key: 'tags',
                criteria: {
                  operator: 'include',
                  value: [tag.id]
                }
              }
            ]
          },
          dimensions: %w(repo)
        }
      end
      let(:tag) { create(:tag) }
      before(:each) do
        issues[0].tags << tag
      end

      it 'returns the chart_values' do
        chart_values
        expect(chart_values).to eq([[
          { x: repo.full_name, y: 1 }
        ]])
      end
    end

    context 'with a has_many :through association filter' do
      let(:properties) do
        {
          measure: {
            key: 'issues',
            filters: [
              {
                key: 'labels',
                criteria: {
                  operator: 'include',
                  value: [label.id]
                }
              }
            ]
          },
          dimensions: %w(repo)
        }
      end
      let(:label) { create(:label) }
      before(:each) do
        issues[0].labels << label
      end

      it 'returns the chart_values' do
        expect(chart_values).to eq([[
          { x: repo.full_name, y: 1 }
        ]])
      end
    end
  end

  context 'with datetime and association dimensions' do
    let(:properties) do
      {
        measure: 'issues',
        dimensions: %w(opened_at repo)
      }
    end
    let!(:issues) do
      [
        create(:issue, repo: repo, opened_at: now),
        create(:issue, repo: repo, opened_at: now - 1.week),
        create(:issue, repo: repo2, opened_at: now)
      ]
    end

    it 'returns the chart_data' do
      expect(chart_data).to eq([
        { key: repo.full_name, values: [{ x: week_offset_timestamp(1), y: 1.0 }, { x: week_offset_timestamp(0), y: 1.0 }] },
        { key: repo2.full_name, values: [{ x: week_offset_timestamp(1), y: 0 }, { x: week_offset_timestamp(0), y: 1.0 }] }
      ])
    end
  end
end
