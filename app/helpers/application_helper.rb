module ApplicationHelper

  # returns an array of symbols that are in the flash object to display
  def flash_messages_display_keys
    [:error, :success, :info]
  end

  # converts a flash key into a CSS class for Bootstrap alerts
  def flash_class_for_key(key)
    keys = { error: 'danger' }
    if keys.key?(key)
      keys[key]
    else
      key.to_s
    end
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Real-Time Productivity"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end
end
