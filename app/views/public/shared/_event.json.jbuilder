json.extract! event, :guid, :title, :subtitle, :slug, :link, :description, :persons, :tags, :date, :release_date, :updated_at
json.length event.length
json.thumb_url event.get_thumb_url
json.poster_url event.get_poster_url
json.frontend_link frontend_link(event)
json.url public_event_url(event, format: :json)
json.conference_url public_conference_url(event.conference, format: :json)
