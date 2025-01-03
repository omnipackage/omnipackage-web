class JsVariables
  include ::Enumerable

  delegate :each, to: :h

  def initialize
    @h = {}
  end

  def set(name, value)
    h[name] = value
    self
  end

  def to_json(*args)
    ::JSON.generate(h, *args)
  end

  private

  attr_reader :h
end
