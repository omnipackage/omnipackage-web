# frozen_string_literal: true

class DocumentationController < ::ApplicationController
  skip_before_action :require_authentication

  # rescue_from ::Errno::ENOENT, with: :respond_not_found

  def index
    content = ::Rails.cache.fetch("documentation/#{current_page}", expires_in: 6.hours) do
      render_md(current_page)
    end
    render(html: content, layout: 'documentation')
  end

  private

  helper_method :sidebar_entries, :current_page

  def current_page
    params[:page] || 'index'
  end

  def sidebar_entries
    ::Rails.cache.fetch("documentation/sidebar", expires_in: 6.hours) do
      ::Dir[::Rails.root.join('documentation/*.md')].map do |entry|
        page = entry.gsub(::Rails.root.join('documentation/').to_s, '').chomp('.md')
        title = entry.split('/').last.chomp('.md').humanize
        [page, title]
      end
    end
  end

  def render_md(path)
    doc_path = ::Rails.root.join('documentation')
    fpath = doc_path.join(path + '.md')
    unless ::File.expand_path(fpath).start_with?(doc_path.to_s)
      raise ::ArgumentError, "path '#{path}' invalid"
    end

    md = ::File.read(fpath)
    ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML).render(md).html_safe # rubocop: disable Rails/OutputSafety
  end
end
