require 'spec_helper'

describe ReportsKit::Reports::Data::Generate do
  subject { described_class.new(properties).perform }

  let(:repo) { create(:repo) }
  let(:repo2) { create(:repo) }
  let(:chart_data) do
    chart_data = subject[:chart_data].except(:options)
    chart_data[:datasets] = chart_data[:datasets].map do |dataset|
      dataset.except(:backgroundColor, :borderColor)
    end
    chart_data
  end

  let!(:issues) do
    [
      create(:issue, repo: repo),
      create(:issue, repo: repo),
      create(:issue, repo: repo2)
    ]
  end

  context 'with a contextual_filter' do
    context 'with context_params' do
      let(:properties) do
        {
          measure: 'issue',
          contextual_filters: %w(for_repo),
          dimensions: %w(repo),
          context_params: { repo_id: repo.id }
        }
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: 'Issues', data: [2] }]
        })
      end
    end

    context 'without context_params' do
      let(:properties) do
        {
          measure: 'issue',
          contextual_filters: %w(for_repo),
          dimensions: %w(repo)
        }
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s, repo2.to_s],
          datasets: [{ label: 'Issues', data: [2, 1] }]
        })
      end
    end
  end
end
