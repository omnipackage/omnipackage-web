# frozen_string_literal: true

module Slug
  module_function

  def regex
    /\A(?!(^xn--|.+-s3alias$))^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]\z/
  end

  def generate(from, max_len: 63)
    from.to_s.parameterize.gsub('_', '-').truncate(max_len, omission: '') # rubocop: disable Performance/StringReplacement
  end
end
