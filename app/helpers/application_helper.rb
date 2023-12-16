# frozen_string_literal: true

module ApplicationHelper
  def dom_friendly(string)
    string.to_s.downcase.gsub(/[^0-9a-z]/i, '-')
  end

  # def show_svg(path)
  #  ::File.open(::Rails.root.join('app/assets/images', path), 'rb') do |file|
  #    raw(file.read)
  #  end
  # end
end
