class ExpireDomainsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    config = Rails.application.config_for(:expiring_domains).with_indifferent_access

    contact = config[:contact]

    # TODO: send out emails

    Domain.all.each do |domain|
      if domain.for_purging?
        domain.destroy!
      end
    end
  end
end
