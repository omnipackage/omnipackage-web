# frozen_string_literal: true

class Duration < ::ActiveSupport::Duration
  def humanized
    i = seconds
    fmt = if i >= 86400
            "#{i.to_i / 86400}d %H:%M:%S"
          elsif i >= 3600
            "%H:%M:%S"
          else
            "%M:%S"
          end
    ::Time.at(i % 86400).utc.strftime(fmt)
  end
end
