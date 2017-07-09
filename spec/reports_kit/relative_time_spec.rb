require 'spec_helper'

describe ReportsKit::RelativeTime do
  subject { described_class.parse(string) }

  Timecop.freeze(TIMECOP_TIME) do
    STRINGS_EXPECTED_VALUES = {
      '2s' => 2.seconds.from_now,
      '-3s' => 3.seconds.ago,
      '4m' => 4.minutes.from_now,
      '5h' => 5.hours.from_now,
      '-6d' => 6.days.ago,
      '7w' => 7.weeks.from_now,
      '8M' => 8.months.from_now,
      '9y' => 9.years.from_now,
      '-2M1w' => (2.months + 1.week).ago
    }
  end

  STRINGS_EXPECTED_VALUES.each do |string, expected_value|
    context string do
      let(:string) { string }

      it 'transforms the filter criteria' do
        expect(subject).to eq(expected_value)
      end
    end
  end
end
