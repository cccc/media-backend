class RecordingView < ActiveRecord::Base
  after_create :update_event_view_count
  validates_presence_of :recording
  belongs_to :recording

  private

  def update_event_view_count
    event = self.recording.event
    event.view_count += 1
    event.save
  end
end
