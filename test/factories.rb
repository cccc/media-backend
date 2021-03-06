FactoryGirl.define do

  sequence :email do |n|
    "test#{n}@example.com"
  end

  sequence :conference_acronym do |n|
    "frabcon#{n}"
  end

  sequence :webgen_location do |n|
    "conference/frabcon" + SecureRandom.hex(16)
  end
  sequence :event_guid do |n|
    SecureRandom.hex(16)
  end

  sequence :event_slug do |n|
    SecureRandom.hex(4)
  end

  sequence :event_title do |n|
    "some event#{n}"
  end

  sequence :tags do |n|
    "tags#{n}"
  end

  factory :api_key do
    key "4"
    description "key"
  end

  factory :conference do
    acronym { generate(:conference_acronym) }
    title "FrabCon"
    recordings_path "events/frabcon123"
    images_path "frabcon123"
    webgen_location { generate(:webgen_location) }
    aspect_ratio "16:9"

    factory :conference_with_recordings, traits: [:conference_recordings, :has_schedule]
  end

  trait :conference_recordings do
    after(:create) do |conference|
      conference.events << FactoryGirl.create(:event_with_recordings)
      conference.events << FactoryGirl.create(:event_with_recordings)
    end
  end

  trait :event_recordings do
    after(:create) do |event|
      event.recordings << FactoryGirl.create(:recording)
      event.recordings << FactoryGirl.create(:recording)
    end
  end

  trait :has_schedule do
    schedule_url "http://localhost/schedule.xml"
    schedule_state "downloaded"
    schedule_xml %{
    <?xml version="1.0" encoding="utf-8"?>
    <schedule>
        <version>1.3final</version>
        <conference>
            <title>SIGINT 2013</title>
            <start>2013-07-05</start>
            <end>2013-07-07</end>
            <days>1</days>
            <timeslot_duration>00:15</timeslot_duration>
        </conference>
        <day date="2013-07-05" index="1">
            <room name="Saal (MP7 OG)">
                <event guid="testGUID" id="5060">
                    <start>11:00</start>
                    <duration>01:00</duration>
                    <room>Saal (MP7 OG)</room>
                    <slug>saal_mp7_og_-_2013-07-05_11:00_-_side_effect_-_mlp_-_5060</slug>
                    <title>Nearly Everything That Matters is a Side Effect</title>
                    <subtitle/>
                    <track>Hacking</track>
                    <type>lecture</type>
                    <language>en</language>
                    <abstract>TBD</abstract>
                    <description>TBD</description>
                    <persons>
                        <person id="1234">mlp</person>
                    </persons>
                    <links>
                    </links>
                </event>
            </room>
        </day>
    </schedule>    
    }
  end

  factory :event do
    conference
    guid { generate(:event_guid) }
    title { generate(:event_title) }
    thumb_filename "frabcon123.jpg"
    poster_filename "frabcon123_logo.jpg"
    subtitle "subtitle"

    slug { generate(:event_slug) }
    link "http://localhost/ev_info"
    description "description"
    persons ["Name"]
    tags ["tag"]
    date "2013-08-21"
    release_date "2013-08-21"

    factory :event_with_recordings, traits: [:event_recordings]
  end

  factory :recording do
    event
    filename "audio.mp3"
    folder ""
    mime_type "video/webm"
    original_url "file:///fixtures/test.webm"
    size "12"
    length "5"
    state "downloaded"
  end

  factory :admin_user do
    email  { generate :email }
    password "admin123"
  end

  factory :news do
    title "MyString"
    body "MyText <b>bold</b> most html allowed."
    date "2014-05-03"
  end

  factory :import_template do
    acronym { generate(:conference_acronym) }
    title "FrabCon"
    recordings_path "events/frabcon123"
    images_path "frabcon123"
    webgen_location { generate(:webgen_location) }
    aspect_ratio "16:9"
    logo "logo.jpg"
    date "2013-08-21"
    release_date "2013-08-21"
    folder "webm"
    mime_type "video/webm"
  end

end
