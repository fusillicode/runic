json.array!(@users) do |user|
  json.extract! user, :username
  json.url api_user_url(user, format: :json)
end
