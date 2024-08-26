# frozen_string_literal: true

class JsVariables
  include ::Enumerable

  delegate :each, to: :h

  def initialize
    @h = {}
  end

  def set(name, value)
    h[name] = value
  end

  def to_json
    ::JSON.dump(h)
  end

  private

  attr_reader :h
end
