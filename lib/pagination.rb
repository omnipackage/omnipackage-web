# frozen_string_literal: true

class Pagination
  attr_reader :page, :per_page, :extend_upto

  def initialize(collection, controller, default_per_page: 15, extend_upto: 30)
    @page =         controller.params[:page]&.to_i || 1
    @per_page =     controller.params[:per_page]&.to_i || default_per_page
    @collection =   collection
    @request_path = ::URI.parse(controller.request.original_fullpath)
    @extend_upto =  extend_upto
  end

  def pages
    @pages ||= (collection.count / per_page.to_f).ceil
  end

  def call
    [self, collection.limit(per_page).offset(offset)]
  end

  def first?
    page == 1
  end

  def last?
    page == pages
  end

  def page_link(topage)
    request_path.dup.tap do |u|
      u.query = query_params.merge('page' => topage).to_query
    end
  end

  def prev_page_link
    return '#' if first?

    page_link(page - 1)
  end

  def next_page_link
    return '#' if last?

    page_link(page + 1)
  end

  def to_h
    {
      page: page,
      per_page: per_page,
      pages: pages
    }
  end

  def extended?
    pages > extend_upto
  end

  def extended_split
    extend_upto / 3
  end

  def omisson?
    pages_shown = extended_split + 1
    (pages_shown..(pages - pages_shown)).cover?(page)
  end

  private

  attr_reader :collection, :request_path

  def offset
    (page - 1) * per_page
  end

  def query_params
    request_path.query&.split('&')&.each_with_object({}) do |elem, acc|
      k, v = elem.split('=')
      acc[k] = v
    end || {}
  end
end
