json.array!(@artists) do |artist|
  json.extract! artist, :name, :created_at, :updated_at, :deleted_at, :del_flg
  json.url artist_url(artist, format: :json)
end