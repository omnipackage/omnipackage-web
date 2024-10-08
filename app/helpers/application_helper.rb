# frozen_string_literal: true

module ApplicationHelper
  def dom_friendly(string)
    string.to_s.downcase.gsub(/[^0-9a-z]/i, '-')
  end
end
