class Json
  def self.lock_values json, id: 1
    locked_json = json.dup

    if locked_json.is_a? Hash
      locked_json.each do |key, value|
        if value.is_a? Array
          value.each_with_index do |v, i|
            value[i] = lock_values(v, id: (i + 1))
          end
        elsif value.is_a? Hash
          locked_json[key] = lock_values(value, id: id)
        else
          locked_json[key] = lock_value(key, value, id: id)
        end
      end
    elsif locked_json.is_a? Array
      locked_json.each_with_index do |value, i|
        locked_json[i] = lock_values value, id: (i + 1)
      end
    end

    locked_json
  end

  def self.lock_value key, value, id: 1
    locked_value = value

    if [:id, :order_number].include? key
      locked_value = id
    end

    if [:created_at, :updated_at, :activity_at, :ordered_at].include? key
      locked_value = '2015-01-01T00:00:00Z'
    end

    locked_value
  end
end
