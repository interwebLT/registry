class Host < ActiveRecord::Base
  belongs_to :partner

  has_many :host_addresses, dependent: :destroy

  validates :partner, presence: true
  validates :name,    presence: true
  validates :name,    uniqueness: true

  before_save :set_host_partner

  private

  def assign_partner_to_host domain_name, current_partner,host_name
    domain  = Domain.find_by_name domain_name

    unless domain.nil?
      if domain.partner != current_partner
        self.partner = domain.partner
        # errors.add(:name, "You are not authorized to register this Nameserver.")
      end
    end
  end

  def set_host_partner
    host_name       = self.name
    unless host_name.nil?
      unless Host.exists?(name: host_name)
        host_array = host_name.split(".")
        current_partner = self.partner

        if host_name.include?(".ph")
          if ["com", "net", "org"].map{|ext| host_name.include?(ext)}.include?(true)
            has_two_valid_extensions = true
          end

          if has_two_valid_extensions
            domain_name = host_array[host_array.length - 3] + "." + host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
          else
            domain_name = host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
          end

          assign_partner_to_host domain_name, current_partner, host_name
        end
      end
    end
  end
end
