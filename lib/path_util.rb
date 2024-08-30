# frozen_string_literal: true

module PathUtil
  module_function

  def join(*parts)
    parts.map do |part|
      part = part[1..-1] if part.start_with?('/')
      part = part[0..-2] if part.end_with?('/')
      part
    end.join('/')
  end
end
