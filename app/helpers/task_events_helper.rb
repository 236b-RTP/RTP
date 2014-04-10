module TaskEventsHelper

  def tags_hash_to_array(tags)
    tags_array = []
    tags.each do |tag_name, tag_colors|
      tag_colors.each do |color|
        tags_array << { label: tag_name, value: tag_name, color: color }
      end
    end
    tags_array
  end

end