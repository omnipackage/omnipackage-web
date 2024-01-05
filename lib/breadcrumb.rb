# frozen_string_literal: true

class Breadcrumb
  include ::Enumerable

  delegate :each, :first, :last, to: :pages

  Page = ::Data.define(:name, :path, :breadcrumb) do
    def active?
      breadcrumb.active && breadcrumb.active.name == name && breadcrumb.active.path == path
    end
  end

  def initialize(view_context)
    @pages = []
    add('Home', view_context.root_path)
  end

  def add(name, path = nil)
    pages << Page.new(name, path, self)
  end

  def active
    last
  end

  private

  attr_reader :pages
end
