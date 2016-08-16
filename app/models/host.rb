class Host < ActiveRecord::Base
  belongs_to :partner

  has_many :host_addresses, dependent: :destroy

  validates :partner, presence: true
  validates :name,    presence: true
  validates :name,    uniqueness: true

  after_save :sync_create

  private

  def sync_create
    ExternalRegistry.all.each do |registry|
      next if registry.name == self.partner.client
      next if ExcludedPartner.exists? name: self.partner.name

      SyncCreateHostJob.perform_later registry.url, self
    end
  end
end
