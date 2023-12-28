# frozen_string_literal: true

class DocsController < ::ApplicationController
  skip_before_action :require_authentication

  # rescue_from ::Errno::ENOENT, with: :respond_not_found

  def index
    content = ::Rails.cache.fetch("docs/#{current_page}", expires_in: 6.hours) do
      render_md(current_page)
    end
    render(html: content, layout: 'docs')
  end

  private

  helper_method :sidebar_entries, :current_page

  def current_page
    params[:page] || 'index'
  end

  def sidebar_entries # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
    ::Rails.cache.fetch("docs/sidebar", expires_in: 6.hours) do
      doc_root = ::Rails.root.join('docs/')
      enum_entries = ->(path) do
        ::Dir[doc_root.join(path, '*.md')].map do |entry|
          page = entry.gsub(doc_root.to_s, '').chomp('.md')
          title = entry.split('/').last.chomp('.md').humanize
          [page, title]
        end
      end
      entries = enum_entries.call(doc_root)

      doc_root.children.select(&:directory?).map do |dir|
        entries << [nil, dir.basename.to_s.chomp('.md').humanize]
        entries.concat(enum_entries.call(dir))
      end

      entries
    end
  end

  def render_md(path)
    doc_path = ::Rails.root.join('docs')
    fpath = doc_path.join(path + '.md')
    unless ::File.expand_path(fpath).start_with?(doc_path.to_s)
      raise ::ArgumentError, "path '#{path}' invalid"
    end

    md = ::File.read(fpath)
    ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML).render(md).html_safe # rubocop: disable Rails/OutputSafety
  end
end
