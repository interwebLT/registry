class HostAddress < ActiveRecord::Base
  attr_accessor :_type_disabled
  self.inheritance_column = :_type_disabled

  belongs_to :host

  validates :address, presence: true
  validates :address, uniqueness: { scope: [:address, :host] }
  validates :type, inclusion: { in: %w(v4 v6) }

  after_save :sync_create

  private

  def sync_create
    ExternalRegistry.all.each do |registry|
      next if registry.name == self.host.partner.client
      next if ExcludedPartner.exists? name: self.host.partner.name

      SyncCreateHostAddressJob.perform_later registry.url, self
    end
  end
end
