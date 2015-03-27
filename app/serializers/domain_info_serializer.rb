class DomainInfoSerializer < DomainSerializer
  attributes  :admin_contact, :billing_contact, :tech_contact,
              :activities, :hosts

  def admin_contact
    ContactSerializer.new(object.admin_contact).serializable_hash if object.admin_contact
  end

  def billing_contact
    ContactSerializer.new(object.billing_contact).serializable_hash if object.billing_contact
  end

  def tech_contact
    ContactSerializer.new(object.tech_contact).serializable_hash if object.tech_contact
  end

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
