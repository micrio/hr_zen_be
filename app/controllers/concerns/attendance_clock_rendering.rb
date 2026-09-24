# frozen_string_literal: true

module AttendanceClockRendering
  extend ActiveSupport::Concern

  private

  def render_clock(result)
    event = result[:event]
    skipped = result[:skipped]

    render_jsonapi(
      {
        event: Api::V1::AttendanceEventSerializer.new(event).serializable_hash,
        user: Api::V1::UserSerializer.new(result[:user]).serializable_hash
      },
      status: skipped ? :ok : :created,
      meta: {
        message: clock_message(result),
        next_action: event.kind == "clock_in" ? "clock_out" : "clock_in",
        skipped: skipped,
        cooldown_remaining: result[:cooldown_remaining],
        distance: result[:distance].to_f.round(4)
      }
    )
  end

  def clock_message(result)
    if result[:skipped]
      return "Just recorded — please wait #{result[:cooldown_remaining]}s."
    end

    result[:event].kind == "clock_in" ? "Clocked in." : "Clocked out."
  end
end
