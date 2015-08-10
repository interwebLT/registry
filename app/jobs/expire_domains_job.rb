class ExpireDomainsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    config = Rails.application.config_for(:expiring_domains).with_indifferent_access

    contact = config[:contact]
    # Do something later
  end
end
