class Host < ActiveRecord::Base
  belongs_to :partner

  has_many :host_addresses, dependent: :destroy

  validates :partner, presence: true
  validates :name,    presence: true
  validates :name,    uniqueness: true

  before_save :set_host_partner

  def top_level_domain
    host_zone = self.name.split(".").last
    host_zone
  end

  def has_valid_second_level_domain
    host_array = self.name.split(".")
    second_level_domain = host_array[host_array.length - 2]

    ["com", "net", "org"].include?(second_level_domain)
  end

  def get_root_domain
    host_name = self.name
    domain_name = ""
    unless host_name.nil?
      host_array = host_name.split(".")

      if self.top_level_domain == "ph"
        if self.has_valid_second_level_domain
          has_two_valid_extensions = true
        end

        if has_two_valid_extensions
          domain_name = host_array[host_array.length - 3] + "." + host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
        else
          domain_name = host_array[host_array.length - 2] + "." + host_array[host_array.length - 1]
        end
      end
    end
    domain_name
  end

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
    host_name   = self.name
    unless Host.exists?(name: host_name)
      domain_name = self.get_root_domain
      current_partner = self.partner
      assign_partner_to_host domain_name, current_partner, host_name
    end
  end
end
