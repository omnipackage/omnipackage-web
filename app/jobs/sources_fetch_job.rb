# frozen_string_literal: true

class SourcesFetchJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = ::Project.find(project_id)
    source = project.sources.sync
    return unless source # TODO: save error message somewhere
    return if !source.config || !source.tarball

    tb = project.sources_tarball || project.build_sources_tarball
    tb.tarball = source.tarball
    tb.config = source.config
    tb.save!
  end
end
