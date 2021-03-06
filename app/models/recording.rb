class Recording < ActiveRecord::Base
  include Recent
  include Download
  include Storage

  belongs_to :event
  has_one :conference, through: :event
  has_many :recording_views, dependent: :destroy

  validates_presence_of :event
  validates :folder, length: { minimum: 0, allow_nil: false, message: "can't be nil" }
  validates_presence_of :filename, :mime_type, :length
  validate :unique_recording

  scope :downloaded, -> { where(state: 'downloaded') }
  scope :video, -> { where(mime_type: %w[vnd.voc/mp4-web vnd.voc/webm-web video/mp4 vnd.voc/h264-lq vnd.voc/h264-hd vnd.voc/h264-sd vnd.voc/webm-hd video/ogg video/webm]) }

  scope :recorded_at, ->(conference) { joins(event: :conference).where(events: {'conference_id' => conference} ) }

  has_attached_file :recording, via: :filename, folder: :folder, belongs_into: :recordings, on: :conference

  state_machine :state, :initial => :new do

    after_transition any => :downloading do |recording, transition|
      recording.download!
    end

    after_transition any => :downloaded do |recording, transition|
      recording.move_files!
    end

    state :new
    state :downloading
    state :downloaded

    event :download_failed do
      transition all => :new
    end

    event :start_download do
      transition all => :downloading
    end

    event :finish_download do
      transition [:downloading] => :downloaded
    end

  end

  def download!
    path = get_tmp_path
    result = download_to_file(self.original_url, path)
    if result and File.readable? path and File.size(path) > 0
      self.finish_download
    else
      self.download_failed
    end
  end
  handle_asynchronously :download!

  def move_files!
    tmp_path = get_tmp_path
    create_recording_dir
    FileUtils.move tmp_path, get_recording_path
  end
  handle_asynchronously :move_files!

  def create_recording_dir
    FileUtils.mkdir_p get_recording_dir
  end

  def display_name
    if self.event.present?
      str = self.event.display_name
    else
     str = self.filename
    end

    return self.id if str.empty?
    str
  end

  def validate_for_api
    self.errors.add(:folder, "recording folder #{self.conference.get_recordings_path} not writable") unless File.writable? self.conference.get_recordings_path
    self.errors.add(:original_url, 'missing original_url') if self.original_url.nil?
    not self.errors.any?
  end

  def unique_recording
    unless self.event.present?
      self.errors.add :event, 'missing event on recording'
      return
    end
    dupe = self.event.recordings.select { |recording|
      recording.filename == self.filename && recording.folder == self.folder
    }.delete_if { |dupe| dupe == self }
    self.errors.add :event, 'recording already exist on event' if dupe.present?
  end

  private

  def get_tmp_path
    File.join(MediaBackend::Application.config.folders[:tmp_dir],
    Digest::MD5.hexdigest(self.filename))
  end

end
