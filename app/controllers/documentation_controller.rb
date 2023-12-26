# frozen_string_literal: true

class DocumentationController < ::ApplicationController
  skip_before_action :require_authentication

  # rescue_from ::Errno::ENOENT, with: :respond_not_found

  def index
    render_md('index')
  end

  def page
    render_md(params[:page])
  end

  private

  helper_method :sidebar_entries

  def sidebar_entries
    ::Dir[::Rails.root.join('documentation', '*.md')].map do |entry|
      page = entry.gsub(::Rails.root.join('documentation/').to_s, '').gsub('.md', '')
      title = entry.split('/').last.gsub('.md', '').humanize
      [page, title]
    end
  end

  def render_md(path)
    raise ::ArgumentError, "path '#{path}' invalid" unless /\A[A-Za-z0-9\/_]+\z/.match?(path)

    fpath = ::Rails.root.join('documentation', path + '.md')
    content = ::File.read(fpath)

    render html: ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML).render(content).html_safe, layout: 'documentation'
  end
end
