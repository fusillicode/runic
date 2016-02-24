json.array!(@runes) do |rune|
  json.extract! rune, :name
  json.extract! rune, :description
  json.url api_rune_url(rune, format: :json)
end
