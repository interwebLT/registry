class SyncUpdateContactJob < ApplicationJob
  queue_as :sync_registry_changes

  def perform url, contact, retry_count = 0
    contact_url = "#{url}/contacts/#{contact.handle}"

    raise 'Max retry reached!' unless retry_count < MAX_SYNC_RETRY_COUNT

    unless check contact_url, token: contact.partner.name
      SyncUpdateContactJob.perform_later url, contact, (retry_count + 1)

      return
    end

    body = {
      name:               contact.name,
      organization:       contact.organization,
      street:             contact.street,
      street2:            contact.street2,
      street3:            contact.street3,
      city:               contact.city,
      state:              contact.state,
      postal_code:        contact.postal_code,
      country_code:       contact.country_code,
      local_name:         contact.local_name,
      local_organization: contact.local_organization,
      local_street:       contact.local_street,
      local_street2:      contact.local_street2,
      local_street3:      contact.local_street3,
      local_city:         contact.local_city,
      local_state:        contact.local_state,
      local_postal_code:  contact.local_postal_code,
      local_country_code: contact.local_country_code,
      voice:              contact.voice,
      voice_ext:          contact.voice_ext,
      fax:                contact.fax,
      fax_ext:            contact.fax_ext,
      email:              contact.email
    }

    patch contact_url, body, token: contact.partner.name
  end
end
