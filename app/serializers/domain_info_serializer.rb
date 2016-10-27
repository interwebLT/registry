class DomainInfoSerializer < DomainSerializer
  attributes  :registrant, :admin_contact, :billing_contact, :tech_contact,
              :hosts, :powerdns_domain, :powerdns_records

  def registrant
    ContactSerializer.new(object.registrant).serializable_hash
  end

  def admin_contact
    ContactSerializer.new(object.admin_contact).serializable_hash if object.admin_contact
  end

  def billing_contact
    ContactSerializer.new(object.billing_contact).serializable_hash if object.billing_contact
  end

  def tech_contact
    ContactSerializer.new(object.tech_contact).serializable_hash if object.tech_contact
  end

  def hosts
    object.product.domain_hosts.order(updated_at: :asc).collect do |host|
      DomainHostSerializer.new(host).serializable_hash
    end
  end

  def powerdns_domain
  end

  def powerdns_records
    if !object.powerdns_domain.nil?
      object.powerdns_domain.powerdns_records.collect do |record|
        Powerdns::RecordSerializer.new(record).serializable_hash
      end
    end
  end
end
