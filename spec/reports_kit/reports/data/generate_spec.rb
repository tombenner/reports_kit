require 'spec_helper'

describe ReportsKit::Reports::Data::Generate do
  subject { described_class.new(properties, context_record: context_record).perform }

  let(:repo) { create(:repo) }
  let(:repo2) { create(:repo) }
  let(:context_record) { nil }
  let(:chart_data) do
    chart_data = subject[:chart_data].except(:options)
    chart_data[:datasets] = chart_data[:datasets].map do |dataset|
      dataset.except(:backgroundColor, :borderColor)
    end
    chart_data
  end
  let(:table_data) do
    subject[:table_data]
  end

  let(:chart_type) { subject[:type] }
  let(:chart_options) { subject[:chart_data][:options] }

  context 'with a datetime dimension' do
    context 'with default granularity' do
      let(:properties) do
        {
          measure: 'issue',
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
            format_week_offset(2),
            format_week_offset(1),
            format_week_offset(0)
          ],
          datasets: [
            {
              label: 'Issues',
              data: [2, 0, 1]
            }
          ]
        })
      end

      context 'with an absolute datetime filter' do
        let(:properties) do
          {
            measure: 'issue',
            filters: [
              {
                key: 'opened_at',
                criteria: {
                  operator: 'between',
                  value: "#{format_configuration_time(now - 1.week)} - #{format_configuration_time(now)}"
                }
              }
            ],
            dimensions: %w(opened_at)
          }
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: 'Issues',
                data: [0, 1]
              }
            ]
          })
        end

        context 'with zero results' do
          let(:properties) do
            {
              measure: 'tag',
              filters: [
                {
                  key: 'created_at',
                  criteria: {
                    operator: 'between',
                    value: "#{format_configuration_time(now - 1.week)} - #{format_configuration_time(now)}"
                  }
                }
              ],
              dimensions: %w(created_at)
            }
          end

          it 'returns the data' do
            expect(chart_data).to eq({
              labels: [
                format_week_offset(1),
                format_week_offset(0)
              ],
              datasets: [
                {
                  label: 'Tags',
                  data: [0, 0]
                }
              ]
            })
          end
        end

        context 'with multiple series and datetime filters with different keys' do
          let!(:tags) do
            [
              create(:tag, repo: repo, created_at: now - 1.weeks),
              create(:tag, repo: repo, created_at: now)
            ]
          end
          let(:properties) do
            {
              series: [
                {
                  measure: 'issue',
                  filters: %w(opened_at),
                  dimensions: %w(opened_at)
                },
                {
                  measure: 'tag',
                  filters: %w(created_at),
                  dimensions: %w(created_at)
                }
              ],
              ui_filters: {
                created_at: "#{format_configuration_time(now - 1.week)} - #{format_configuration_time(now)}"
              }
            }
          end

          it 'returns the chart_data' do
            expect(chart_data).to eq({
              labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
              datasets: [
                {
                  label: 'Issues',
                  data: [2, 0, 1]
                },
                {
                  label: 'Tags',
                  data: [0, 1, 1]
                }
              ]
            })
          end
        end
      end

      context 'with a relative datetime filter' do
        let(:properties) do
          {
            measure: 'issue',
            filters: [
              {
                key: 'opened_at',
                criteria: {
                  operator: 'between',
                  value: '-1w - now'
                }
              }
            ],
            dimensions: %w(opened_at)
          }
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: 'Issues',
                data: [0, 1]
              }
            ]
          })
        end

        context 'when a record\'s timestamp is closer to the beginning of the week than the current date' do
          let!(:issues) do
            [
              create(:issue, repo: repo, opened_at: Date.parse('2009-12-22'))
            ]
          end

          it 'includes record' do
            expect(chart_data).to eq({
              labels: [format_week_offset(1), format_week_offset(0)],
              datasets: [
                {
                  label: 'Issues',
                  data: [1, 0]
                }
              ]
            })
          end
        end
      end
    end

    context 'with day granularity' do
      let(:properties) do
        {
          measure: 'issue',
          dimensions: [{ key: 'opened_at', granularity: 'day' }]
        }
      end
      let!(:issues) do
        [
          create(:issue, repo: repo, opened_at: now - 2.days),
          create(:issue, repo: repo, opened_at: now)
        ]
      end

      it 'returns the data' do
        expect(chart_data).to eq({
          labels: [
            format_day_offset(2),
            format_day_offset(1),
            format_day_offset(0)
          ],
          datasets: [
            {
              label: 'Issues',
              data: [1, 0, 1]
            }
          ]
        })
      end
    end
  end

  context 'with an association dimension' do
    let(:properties) do
      {
        measure: 'issue',
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
          datasets: [{ label: 'Issues', data: [2.0] }]
        })
      end
    end

    context 'with a limit' do
      let(:properties) do
        {
          measure: 'issue',
          dimensions: %w(repo),
          limit: 1
        }
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: 'Issues', data: [2] }]
        })
      end
    end

    context 'with a dimension limit' do
      let(:properties) do
        {
          measure: 'issue',
          dimensions: [{ key: 'repo', limit: 1 }]
        }
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: 'Issues', data: [2] }]
        })
      end
    end

    context 'with a custom aggregation' do
      let(:properties) do
        {
          measure: {
            key: 'issue',
            name: 'Average Durations',
            aggregation: 'average_duration'
          },
          dimensions: %w(repo)
        }
      end
      let!(:issues) do
        [
          create(:issue, repo: repo, opened_at: now, closed_at: now),
          create(:issue, repo: repo, opened_at: now - 2.weeks, closed_at: now),
          create(:issue, repo: repo2, opened_at: now - 2.weeks, closed_at: now)
        ]
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo2.to_s, repo.to_s],
          datasets: [{ label: 'Average Durations', data: [14, 7] }]
        })
      end
    end

    context 'with a belongs_to association filter' do
      let(:properties) do
        {
          measure: 'issue',
          filters: [
            {
              key: 'repo',
              criteria: {
                operator: 'include',
                value: [repo.id]
              }
            }
          ],
          dimensions: %w(repo)
        }
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo.to_s],
          datasets: [{ label: 'Issues', data: [2.0] }]
        })
      end
    end

    context 'with a has_many association filter' do
      let(:properties) do
        {
          measure: 'issue',
          filters: [
            {
              key: 'tags',
              criteria: {
                operator: 'include',
                value: [tag.id]
              }
            }
          ],
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
          datasets: [{ label: 'Issues', data: [1.0] }]
        })
      end
    end

    context 'with a has_many :through association filter' do
      let(:properties) do
        {
          measure: 'issue',
          filters: [
            {
              key: 'labels',
              criteria: {
                operator: 'include',
                value: [label.id]
              }
            }
          ],
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
          datasets: [{ label: 'Issues', data: [1.0] }]
        })
      end
    end
  end

  context 'with a boolean dimension' do
    let(:properties) do
      {
        measure: 'issue',
        dimensions: %w(locked)
      }
    end
    let!(:issues) do
      [
        create(:issue, locked: true),
        create(:issue, locked: false),
        create(:issue, locked: false)
      ]
    end

    it 'returns the chart_data' do
      expect(chart_data).to eq({
        labels: ['false', 'true'],
        datasets: [{ label: 'Issues', data: [2, 1] }]
      })
    end
  end

  context 'with datetime and association dimensions' do
    let(:properties) do
      {
        measure: 'issue',
        dimensions: [
          { key: 'opened_at', label: nil },
          { key: 'repo' }
        ]
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
        labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
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

    context "with format: 'csv'" do
      subject { described_class.new(properties.merge(format: 'csv'), context_record: context_record).perform }

      it 'returns the table_data' do
        expect(table_data).to eq([
          [nil, repo.to_s, repo2.to_s],
          [format_csv_week_offset(2), 1, 0],
          [format_csv_week_offset(1), 0, 0],
          [format_csv_week_offset(0), 1, 1]
        ])
      end

      context 'with a data_format_method that adds HTML tags' do
        subject { described_class.new(properties.merge(format: 'csv', data_format_method: 'add_label_link'), context_record: context_record).perform }

        it 'returns the table_data without the HTML tags' do
          expect(table_data).to eq([
            [nil, repo.to_s, repo2.to_s],
            ["#{format_csv_week_offset(2)} Bar", 1, 0],
            ["#{format_csv_week_offset(1)} Bar", 0, 0],
            ["#{format_csv_week_offset(0)} Bar", 1, 1]
          ])
        end
      end
    end

    context "with format: 'table'" do
      subject { described_class.new(properties.merge(format: 'table'), context_record: context_record).perform }

      it 'returns the table_data' do
        expect(table_data).to eq([
          [nil, repo.to_s, repo2.to_s],
          [format_week_offset(2), 1, 0],
          [format_week_offset(1), 0, 0],
          [format_week_offset(0), 1, 1]
        ])
      end

      context 'with a data_format_method that adds HTML tags' do
        subject { described_class.new(properties.merge(format: 'table', data_format_method: 'add_label_link'), context_record: context_record).perform }

        it 'returns the table_data with the HTML tags' do
          expect(table_data).to eq([
            [nil, repo.to_s, repo2.to_s],
            ["<a href='#'>#{format_week_offset(2)}</a> Bar", 1, 0],
            ["<a href='#'>#{format_week_offset(1)}</a> Bar", 0, 0],
            ["<a href='#'>#{format_week_offset(0)}</a> Bar", 1, 1]
          ])
        end
      end
    end

    context 'with a data_format_method' do
      subject { described_class.new(properties.merge(data_format_method: 'add_label_suffix'), context_record: context_record).perform }

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: ["#{format_week_offset(2)} Foo", "#{format_week_offset(1)} Foo", "#{format_week_offset(0)} Foo"],
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

      context 'with dependence on the context_record' do
        subject { described_class.new(properties.merge(data_format_method: 'add_context_record_suffix'), context_record: context_record).perform }
        let(:context_record) { repo }

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: ["#{format_week_offset(2)} #{context_record}", "#{format_week_offset(1)} #{context_record}", "#{format_week_offset(0)} #{context_record}"],
            datasets: [
              {
                label: repo.to_s,
                data: [1, 0, 1]
              }
            ]
          })
        end
      end
    end

    context 'with an edit_relation_method' do
      subject { described_class.new(properties.merge(report_options: { edit_relation_method: 'empty_result_set_for_relation' }), context_record: context_record).perform }

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [],
          datasets: [
            {
              label: 'Issues',
              data: []
            }
          ]
        })
      end
    end
  end

  context 'with a dimension with a blank label' do
    let(:properties) do
      {
        measure: 'issue',
        dimensions: %w(repo)
      }
    end

    before do
      allow_any_instance_of(Repo).to receive(:to_s).and_return(nil)
    end

    it 'hides the dimension' do
      expect(chart_data).to eq({
        labels: [],
        datasets: [
          {
            label: 'Issues',
            data: []
          }
        ]
      })
    end
  end

  context 'with two series' do
    let(:properties) do
      {
        series: [
          {
            measure: 'issue',
            dimensions: [{ key: 'created_at', label: nil }]
          },
          {
            measure: 'tag',
            dimensions: %w(created_at)
          }
        ]
      }
    end
    let!(:issues) do
      [
        create(:issue, repo: repo, created_at: now),
        create(:issue, repo: repo, created_at: now - 2.weeks),
        create(:issue, repo: repo2, created_at: now)
      ]
    end
    let!(:tags) do
      [
        create(:tag, repo: repo, created_at: now - 1.week),
        create(:tag, repo: repo, created_at: now - 2.weeks)
      ]
    end

    it 'returns the chart_data' do
      expect(chart_data).to eq({
        labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
        datasets: [
          {
            label: 'Issues',
            data: [1, 0, 2]
          },
          {
            label: 'Tags',
            data: [1, 1, 0]
          }
        ]
      })
    end

    context 'with concurrent queries enabled' do
      around :each do |example|
        ReportsKit.configuration.use_concurrent_queries = true
        example.run
        ReportsKit.configuration.use_concurrent_queries = false
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
          datasets: [
            {
              label: 'Issues',
              data: [1, 0, 2]
            },
            {
              label: 'Tags',
              data: [1, 1, 0]
            }
          ]
        })
      end
    end

    context "with format: 'table'" do
      subject { described_class.new(properties.merge(format: 'table'), context_record: context_record).perform }

      it 'returns the table_data' do
        expect(table_data).to eq([
          [nil, 'Issues', 'Tags'],
          [format_week_offset(2), 1, 1],
          [format_week_offset(1), 0, 1],
          [format_week_offset(0), 2, 0]
        ])
      end
    end
  end

  context 'with two dimensions' do
    context 'with a custom aggregation' do
      let(:properties) do
        {
          measure: {
            key: 'issue',
            aggregation: 'average_duration'
          },
          dimensions: %w(repo created_at)
        }
      end
      let!(:issues) do
        [
          create(:issue, repo: repo, opened_at: now, closed_at: now),
          create(:issue, repo: repo, opened_at: now - 2.weeks, closed_at: now),
          create(:issue, repo: repo2, opened_at: now - 2.weeks, closed_at: now)
        ]
      end

      it 'returns the chart_data' do
        expect(chart_data).to eq({
          labels: [repo2.to_s, repo.to_s],
          datasets: [{ label: format_week_offset(0), data: [14, 7] }]
        })
      end
    end
  end

  describe 'configuration' do
    let(:properties) do
      {
        measure: 'issue',
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

    context 'with default_properties' do
      around :each do |example|
        ReportsKit.configuration.default_properties = {
          chart: {
            options: {
              foo: 'bar'
            }
          }
        }
        example.run
        ReportsKit.configuration.default_properties = nil
      end

      it 'returns the chart_data' do
        expect(subject[:chart_data][:options][:foo]).to eq('bar')
      end
    end
  end

  describe 'composite aggregations' do
    context 'with two series' do
      let(:properties) do
        {
          name: name,
          composite_operator: composite_operator,
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
      end
      let!(:issues) do
        [
          create(:issue, repo: repo, created_at: now),
          create(:issue, repo: repo, created_at: now - 2.weeks),
          create(:issue, repo: repo2, created_at: now)
        ]
      end
      let!(:tags) do
        [
          create(:tag, repo: repo, created_at: now),
          create(:tag, repo: repo, created_at: now - 1.week),
          create(:tag, repo: repo, created_at: now - 1.week)
        ]
      end
      let(:name) { 'My Name' }

      context 'with +' do
        let(:composite_operator) { '+' }

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: name,
                data: [1, 2, 3]
              }
            ]
          })
        end
      end

      context 'with %' do
        let(:composite_operator) { '%' }

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: name,
                data: [0, 0, 200]
              }
            ]
          })
        end
      end

      context 'with % and a custom value_format_method' do
        let(:composite_operator) { '%' }
        let(:properties) do
          {
            name: name,
            composite_operator: composite_operator,
            value_format_method: 'format_percentage',
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
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: name,
                data: ['0%', '0%', '200%']
              }
            ]
          })
        end
      end

      context 'with a limit' do
        let(:properties) do
          {
            name: name,
            composite_operator: '+',
            limit: 1,
            series: [
              {
                measure: 'issue',
                dimensions: %w(repo)
              },
              {
                measure: 'tag',
                dimensions: %w(repo)
              }
            ]
          }
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [repo.to_s],
            datasets: [
              {
                label: name,
                data: [5]
              }
            ]
          })
        end
      end

      context 'with a limit and an order' do
        context 'with an ascending order' do
          let(:properties) do
            {
              name: name,
              composite_operator: '%',
              limit: 1,
              order: '1',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(repo)
                },
                {
                  measure: 'tag',
                  dimensions: %w(repo)
                }
              ]
            }
          end

          it 'returns the chart_data' do
            expect(chart_data).to eq({
              labels: [repo2.to_s],
              datasets: [
                {
                  label: name,
                  data: [0]
                }
              ]
            })
          end
        end

        context 'with a descending order' do
          let(:properties) do
            {
              name: name,
              composite_operator: '%',
              limit: 1,
              order: '1 desc',
              series: [
                {
                  measure: 'issue',
                  dimensions: %w(repo)
                },
                {
                  measure: 'tag',
                  dimensions: %w(repo)
                }
              ]
            }
          end

          it 'returns the chart_data' do
            expect(chart_data).to eq({
              labels: [repo.to_s],
              datasets: [
                {
                  label: name,
                  data: [66.7]
                }
              ]
            })
          end
        end
      end

      context 'with a boolean dimension' do
        let!(:issues) do
          [
            create(:issue, locked: true),
            create(:issue, locked: false),
            create(:issue, locked: false)
          ]
        end
        let(:composite_operator) { '+' }
        let(:properties) do
          {
            name: name,
            composite_operator: composite_operator,
            series: [
              {
                measure: 'issue',
                dimensions: %w(locked)
              },
              {
                measure: 'issue',
                dimensions: %w(locked)
              }
            ]
          }
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: ['false', 'true'],
            datasets: [
              {
                label: name,
                data: [4, 2]
              }
            ]
          })
        end
      end

      context 'with a nested composite aggregation' do
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
                  },
                  {
                    measure: 'tag',
                    dimensions: %w(created_at)
                  }
                ]
              },
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
        end

        it 'returns the chart_data' do
          expect(chart_data).to eq({
            labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
            datasets: [
              {
                label: name,
                data: [1, 2, 3]
              },
              {
                label: 'Issues',
                data: [1, 0, 2]
              },
              {
                label: 'Tags',
                data: [0, 2, 1]
              }
            ]
          })
        end

        context 'with ui_filters' do
          let(:properties) do
            {
              series: [
                {
                  name: name,
                  composite_operator: '+',
                  series: [
                    {
                      measure: 'issue',
                      filters: %w(created_at),
                      dimensions: %w(created_at)
                    },
                    {
                      measure: 'tag',
                      filters: %w(created_at),
                      dimensions: %w(created_at)
                    }
                  ]
                },
                {
                  measure: 'issue',
                  filters: %w(created_at),
                  dimensions: %w(created_at)
                },
                {
                  measure: 'tag',
                  filters: %w(created_at),
                  dimensions: %w(created_at)
                }
              ],
              ui_filters: {
                created_at: "#{format_configuration_time(now - 1.week)} - #{format_configuration_time(now)}"
              }
            }
          end

          it 'returns the chart_data' do
            expect(chart_data).to eq({
              labels: [format_week_offset(1), format_week_offset(0)],
              datasets: [
                {
                  label: name,
                  data: [2, 3]
                },
                {
                  label: 'Issues',
                  data: [0, 2]
                },
                {
                  label: 'Tags',
                  data: [2, 1]
                }
              ]
            })
          end
        end

        context 'with two dimensions' do
          let(:properties) do
            {
              series: [
                {
                  name: name,
                  composite_operator: '+',
                  series: [
                    {
                      measure: 'issue',
                      dimensions: %w(created_at repo)
                    },
                    {
                      measure: 'tag',
                      dimensions: %w(created_at repo)
                    }
                  ]
                }
              ]
            }
          end

          it 'returns the chart_data' do
            expect(chart_data).to eq({
              labels: [format_week_offset(2), format_week_offset(1), format_week_offset(0)],
              datasets: [
                {
                  label: repo.to_s,
                  data: [1, 2, 2]
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
    end
  end

  # These examples allow for quick comparisons of many types of inputs and outputs.
  # When making functional modifications, run these to see whether the modifications impact the output in any cases.
  # If the output effects are desired, run `REWRITE_RESULTS=1 rspec` to write them to the outputs YAML file, then verify that the output
  # modifications are desired, then commit the result and uncomment the `skip`.
  describe 'YAML-based output comparisons' do
    FIXTURES_DIRECTORY = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'fixtures'))

    let(:inputs) { YAML.load_file("#{FIXTURES_DIRECTORY}/generate_inputs.yml") }
    let(:outputs_path) { "#{FIXTURES_DIRECTORY}/generate_outputs.yml" }
    let(:outputs) { YAML.load_file(outputs_path) }

    let!(:repo) { create(:repo, full_name: 'foo/bar1') }
    let!(:repo2) { create(:repo, full_name: 'foo/bar2') }
    let!(:issues) do
      [
        create(:issue, repo: repo, state: 'open', opened_at: now - 2.weeks),
        create(:issue, repo: repo, state: 'closed', opened_at: now)
      ]
    end
    let!(:labels) do
      [
        create(:label, repo: repo),
        create(:label, repo: repo2),
        create(:label, repo: repo2)
      ]
    end

    context 'input examples' do
      YAML.load_file("#{FIXTURES_DIRECTORY}/generate_inputs.yml").each.with_index do |inputs, index|
        it "returns the expected output for input ##{index}: #{inputs.to_json}" do
          expect(described_class.new(inputs).perform.to_yaml).to eq(outputs[index].to_yaml)
        end
      end
    end

    context 'writing the outputs' do
      it 'writes the outputs' do
        # For documentation about this `skip`, see the comment at the top of this `describe` block.
        skip unless ENV['REWRITE_RESULTS'] == '1'

        outputs = inputs.map do |example|
          described_class.new(example).perform
        end
        File.write(outputs_path, outputs.to_yaml)
      end
    end
  end
end
