require 'spec_helper'

describe ReportsKit::Reports::GenerateAutocompleteResults do
  subject { described_class.new(params, properties).perform }
  let!(:repo) { create(:repo) }
  let!(:repo2) { create(:repo) }
  let!(:issues) do
    [
      create(:issue, repo: repo, opened_at: now - 2.weeks),
      create(:issue, repo: repo2, opened_at: now - 2.weeks),
      create(:issue, repo: repo, opened_at: now)
    ]
  end

  context 'with valid params' do
    let(:params) { { key: 'repo' } }
    let(:properties) do
      {
        measure: 'issue',
        filters: %w(repo),
        dimensions: %w(opened_at)
      }
    end

    it 'returns the results' do
      expect(subject).to eq([
        { id: repo.id, text: repo.to_s },
        { id: repo2.id, text: repo2.to_s }
      ])
    end
  end

  context 'with a contextual_filter' do
    context 'with context_params' do
      let(:params) { { key: 'repo', context_params: { repo_id: repo.id } } }
      let(:properties) do
        {
          measure: 'issue',
          filters: [{ key: 'repo', contextual_filters: %w(for_repo) }],
          dimensions: %w(opened_at)
        }
      end

      it 'returns the results' do
        expect(subject).to eq([
          { id: repo.id, text: repo.to_s }
        ])
      end
    end

    context 'without context_params' do
      let(:params) { { key: 'repo' } }
      let(:properties) do
        {
          measure: 'issue',
          filters: [{ key: 'repo', contextual_filters: %w(for_repo) }],
          dimensions: %w(opened_at)
        }
      end

      it 'returns the results' do
        expect(subject).to eq([
          { id: repo.id, text: repo.to_s },
          { id: repo2.id, text: repo2.to_s }
        ])
      end
    end
  end
end
