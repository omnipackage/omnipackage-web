# frozen_string_literal: true

class Slug
  attr_reader :max_len

  def initialize(max_len: 63)
    @max_len = max_len
  end

  def regex
    /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,#{max_len}}[a-z0-9]\z/
  end

  def generate(from)
    result = from.to_s.parameterize.gsub('_', '-').truncate(max_len, omission: '') # rubocop: disable Performance/StringReplacement
    raise "generated slug '#{result}' from '#{from}' does not pass validation regex'" if from.present? && !regex.match?(result)

    result
  end
end
