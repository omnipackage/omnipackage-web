module PathUtil
  module_function

  def join(*parts, no_dots: true) # rubocop: disable Metrics/CyclomaticComplexity
    parts.reject(&:empty?).map do |part|
      part = part[1..-1] while part.start_with?('/')
      part = part[0..-2] while part.end_with?('/')
      raise "cannot have '#{part}' in path" if no_dots && (part == '.' || part == '..')

      part
    end.join('/')
  end
end
