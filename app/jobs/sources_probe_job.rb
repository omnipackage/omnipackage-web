# frozen_string_literal: true

class SourcesProbeJob < ::ApplicationJob
  def perform(project_id)
    project = ::Project.find(project_id)
    if project.sources.probe
      project.sources_verified!
    end
  end
end
