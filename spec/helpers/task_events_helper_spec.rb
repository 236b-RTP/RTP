require 'spec_helper'

describe TaskEventsHelper do
  context '#tags_hash_to_array' do
    let (:single_color_tag) { { "tag_name" => ["black"] } }
    let (:multi_color_tag) { { "tag_name" => ["black", "blue"] } }

    it 'returns an empty array when given an empty hash' do
      expect(helper.tags_hash_to_array({})).to eq([])
    end

    it 'returns an array containing one hash when a tag has only one color' do
      expect(helper.tags_hash_to_array(single_color_tag)).to eq([{ :label => "tag_name", :value => "tag_name", :color => "black" }])
    end

    it 'returns an array containing more than one hash when a tag has more than one color' do
      expect(helper.tags_hash_to_array(multi_color_tag)).to eq([{ :label => "tag_name", :value => "tag_name", :color => "black" }, { :label => "tag_name", :value => "tag_name", :color => "blue" }])
    end
  end
end