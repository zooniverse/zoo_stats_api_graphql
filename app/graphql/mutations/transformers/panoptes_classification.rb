module Transformers
  class PanoptesClassification
    attr_accessor :payload

    def initialize(payload)
      @payload = payload
    end

    def transform
      {
        event_id:        id,
        event_type:      type,
        event_source:    source,
        event_time:      finished_at,
        project_id:      project,
        workflow_id:     workflow,
        user_id:         user,
        data:            remaining_data,
        session_time:    session_time
      }
    end

    private
    def remaining_data
      {
        subject_id:         subject_id,
        created_at:          created_at,
        updated_at:          updated_at,
        workflow_version:    workflow_version,
        gold_standard:       gold_standard,
        expert_classifier:   expert_classifier,
        metadata:            output_metadata
      }
    end

    def output_metadata
      {
        started_at:     started_at,
        finished_at:    finished_at,
        session:        session,
        utc_offset:     utc_offset,
        user_language:  user_language
      }
    end

    def type
      payload.dig("type")
    end

    def source
      payload.dig("source")
    end

    def id
      payload.dig("data", "id")
    end

    def project
      payload.dig("data", "links", "project")
    end

    def workflow
      payload.dig("data", "links", "workflow")
    end

    def user
      payload.dig("data", "links", "user")
    end

    def subject_id
      payload.dig("data", "links", "subjects").first
    end

    def created_at
      DateTime.parse(payload.dig("data", "created_at")) if payload.dig("data", "created_at")
    end

    def updated_at
      DateTime.parse(payload.dig("data", "updated_at")) if payload.dig("data", "updated_at")
    end

    def workflow_version
      payload.dig("data", "workflow_version")
    end

    def gold_standard
      payload.dig("data", "gold_standard")
    end

    def expert_classifier
      payload.dig("data", "expert_classifier")
    end

    def started_at
      DateTime.parse(payload.dig("data", "metadata", "started_at")) if payload.dig("data", "metadata", "started_at")
    end

    def finished_at
      DateTime.parse(payload.dig("data", "metadata", "finished_at")) if payload.dig("data", "metadata", "finished_at")
    end

    def session
      payload.dig("data", "metadata", "session")
    end

    def utc_offset
      payload.dig("data", "metadata", "utc_offset")
    end

    def user_language
      payload.dig("data", "metadata", "user_language")
    end

    def session_time
      diff = finished_at.to_i - started_at.to_i
      diff.to_f
    end
  end
end