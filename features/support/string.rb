class String
  def json
    JSON.parse File.read("features/assets/#{self}.json").strip, symbolize_names: true
  end
end
