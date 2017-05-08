require 'spec_helper'

describe ReportsKit::Reports::Data::Generate do
  subject { described_class.new(properties, context_record: context_record).perform }

  let(:repo) { create(:repo) }
  let(:repo2) { create(:repo) }
  let(:context_record) { nil }
  let(:chart_data) do
    chart_data = subject[:chart_data].except(:options)
    chart_data[:datasets] = chart_data[:datasets].map do |dataset|
      dataset.except(:backgroundColor)
    end
    chart_data
  end

  let(:chart_type) { subject[:type] }

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

    it 'returns the type' do
      expect(chart_type).to eq('bar')
    end

    it 'returns the data' do
      expect(chart_data).to eq({
        labels: [
          format_time(2),
          format_time(1),
          format_time(0)
        ],
        datasets: [
          {
            label: 'Issues',
            data: [2, 0, 1]
          }
        ]
      })
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

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [format_time(0)],
          datasets: [
            {
              label: "Issues",
              data: [1.0]
            }
          ]
        })
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

    it 'returns the chart_data' do
      expect(chart_data).to eq({
        labels: [repo.to_s, repo2.to_s],
        datasets: [{ label: 'Issues', data: [2, 1] }]
      })
    end

    context 'with a context_record' do
      let(:context_record) { repo }

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: "Issues", data: [2.0] }]
        })
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

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: "Issues", data: [2.0] }]
        })
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

      it 'returns the chart_data' do
        chart_data
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: "Issues", data: [1.0] }]
        })
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

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: "Issues", data: [1.0] }]
        })
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
        create(:issue, repo: repo, opened_at: now - 2.weeks),
        create(:issue, repo: repo2, opened_at: now)
      ]
    end

    it 'returns the chart_data' do
      expect(chart_data).to eq({
        labels: [format_time(2), format_time(1), format_time(0)],
        datasets: [
          {
            label: repo.to_s,
            data: [1, 0, 1]
          },
          {
            label: repo2.to_s,
            data: [0, 0, 1]
          }
        ]
      })
    end
  end
end
