require 'spec_helper'

describe 'Time Utilities' do
  describe '.change_dt' do
    before do
      @begin_time = DateTime.now
    end

    it 'returns the same time if zero is given as the amount' do
      expect(change_dt(@begin_time, 0)).to eq(@begin_time)
    end

    it 'returns the correct time if a positive amount is given' do
      expect(change_dt(@begin_time, 6)).to eq(@begin_time + 6.hours)
    end

    it 'returns the correct time if a negative amount is given' do
      expect(change_dt(@begin_time, -6)).to eq(@begin_time - 6.hours)
    end
  end

  describe '.make_date' do
    pending
  end

  describe '.change_dt_sec' do
    before do
      @begin_time = DateTime.now
    end

    it 'returns the same time if zero is given as the amount' do
      expect(change_dt_sec(@begin_time, 0)).to eq(@begin_time)
    end

    it 'returns the correct time if a positive amount is given' do
      expect(change_dt_sec(@begin_time, 360)).to eq(@begin_time + 360.seconds)
    end

    it 'returns the correct time if a negative amount is given' do
      expect(change_dt_sec(@begin_time, -360)).to eq(@begin_time - 360.seconds)
    end
  end

  describe '.multi_arr_empty?' do
    it 'returns true for an empty array' do
      expect(multi_arr_empty?([])).to be_true
    end

    it 'returns true for an array containing only an empty array' do
      expect(multi_arr_empty?([[]])).to be_true
    end

    it 'returns true for an array containing more than one empty array' do
      expect(multi_arr_empty?([[], [], []])).to be_true
    end

    it 'returns false for an array containing only a non-empty array' do
      expect(multi_arr_empty?([[1]])).to be_false
    end

    it 'returns false for an array containing a non-empty array and an empty array' do
      expect(multi_arr_empty?([[1], []])).to be_false
    end
  end
end