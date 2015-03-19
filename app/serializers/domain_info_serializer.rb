class DomainInfoSerializer < DomainSerializer
  attributes :activities, :hosts

  def activities
    object.domain_activities.order(id: :asc).collect do |activity|
      activity.as_json
    end
  end

  def hosts
    object.product.domain_hosts.order(name: :asc).collect do |host|
      DomainHostSerializer.new(host).serializable_hash
    end
  end
end
