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

  def to_page_title_part
    return '' if count <= 1

    " - #{active.name}"
  end

  private

  attr_reader :pages
end
