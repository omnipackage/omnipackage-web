# frozen_string_literal: true

class DocumentationController < ::ApplicationController
  skip_before_action :require_authentication

  # rescue_from ::Errno::ENOENT, with: :respond_not_found

  def index
    render_md(current_page)
  end

  private

  helper_method :sidebar_entries, :current_page

  def current_page
    params[:page] || 'index'
  end

  def sidebar_entries
    ::Dir[::Rails.root.join('documentation/*.md')].map do |entry|
      page = entry.gsub(::Rails.root.join('documentation/').to_s, '')
      title = entry.split('/').last.gsub('.md', '').humanize
      [page, title]
    end
  end

  def render_md(path)
    doc_path = ::Rails.root.join('documentation')
    fpath = doc_path.join(path + '.md')
    unless ::File.expand_path(fpath).start_with?(doc_path.to_s)
      raise ::ArgumentError, "path '#{path}' invalid"
    end

    content = ::File.read(fpath)
    render(html: ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML).render(content).html_safe, layout: 'documentation') # rubocop: disable Rails/OutputSafety
  end
end
