require 'spec_helper'

describe ReportsKit::Reports::Data::NormalizeProperties do
  describe '#perform' do
    let(:normalized_properties) { described_class.new(properties).perform }
    let(:series) { normalized_properties[:series] }
    let(:context_params) { { foo: 'bar' } }
    let(:name) { 'Foo' }

    context 'without a series key' do
      let(:properties) do
        {
          measure: 'issue',
          dimensions: %w(opened_at)
        }
      end

      it 'normalizes' do
        expect(series).to eq([properties])
      end
    end

    context 'with a series key' do
      let(:properties) do
        {
          series: {
            measure: 'issue',
            dimensions: %w(opened_at)
          }
        }
      end

      it 'normalizes' do
        expect(series).to eq([properties[:series]])
      end
    end

    context 'with a series array and context_params' do
      let(:properties) do
        {
          series: [{
            measure: 'issue',
            dimensions: %w(opened_at)
          }],
          context_params: context_params
        }
      end

      it 'normalizes' do
        expect(series).to eq([{
          measure: 'issue',
          dimensions: %w(opened_at),
          context_params: context_params
        }])
      end
    end

    context 'with a composite series and context_params' do
      let(:properties) do
        {
          name: name,
          composite_operator: '%',
          series: [
            {
              measure: 'issue',
              dimensions: %w(created_at)
            },
            {
              measure: 'tag',
              dimensions: %w(created_at)
            }
          ],
          context_params: context_params
        }
      end

      it 'copies the context_params to the series' do
        expect(normalized_properties).to eq({
          name: name,
          composite_operator: '%',
          series: [
            {
              measure: 'issue',
              dimensions: %w(created_at),
              context_params: context_params
            },
            {
              measure: 'tag',
              dimensions: %w(created_at),
              context_params: context_params
            }
          ],
          context_params: context_params
        })
      end
    end

    context 'with a composite series and context_params' do
      let(:properties) do
        {
          series: [
            {
              name: name,
              composite_operator: '+',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(created_at)
                }
              ]
            }
          ],
          context_params: context_params
        }
      end

      it 'copies the context_params to the series' do
        expect(normalized_properties).to eq({
          series: [
            {
              name: name,
              composite_operator: '+',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(created_at),
                  context_params: context_params
                }
              ],
              context_params: context_params
            }
          ],
          context_params: context_params
        })
      end
    end

    context 'with a composite series, a series, and context_params' do
      let(:properties) do
        {
          series: [
            {
              measure: 'issue',
              dimensions: %w(opened_at)
            },
            {
              name: name,
              composite_operator: '%',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(created_at)
                },
                {
                  measure: 'tag',
                  dimensions: %w(created_at)
                }
              ]
            }
          ],
          context_params: context_params
        }
      end

      it 'copies the context_params to the series' do
        expect(normalized_properties).to eq({
          series: [
            {
              measure: 'issue',
              dimensions: %w(opened_at),
              context_params: context_params
            },
            {
              name: name,
              composite_operator: '%',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(created_at),
                  context_params: context_params
                },
                {
                  measure: 'tag',
                  dimensions: %w(created_at),
                  context_params: context_params
                }
              ],
              context_params: context_params
            }
          ],
          context_params: context_params
        })
      end
    end
  end
end
