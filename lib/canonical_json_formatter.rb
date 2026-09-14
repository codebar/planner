# frozen_string_literal: true

# JSON formatter for the canonical stdout log lines.
#
# SemanticLogger's stock JSON formatter emits redundant fields; this subclass
# drops them so each line carries one value per concept:
# - duration: the human string form of duration_ms
# - level_index: internal enum, derivable from level
# - payload.status_message: derivable from status
class CanonicalJsonFormatter < SemanticLogger::Formatters::Json
  def level
    hash[:level] = log.level
  end

  def duration
    hash[:duration_ms] = log.duration if log.duration
  end

  def payload
    super
    hash[:payload]&.delete(:status_message)
  end
end
