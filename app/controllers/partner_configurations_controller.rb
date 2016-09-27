class PartnerConfigurationsController < SecureController
  def create
    success = true
    partner = Partner.find_by_name params[:partner]
    ns_for_add    = params[:ns_for_add].nil? ? "" : params[:ns_for_add]
    ns_for_remove = params[:ns_for_remove].nil? ? "" : params[:ns_for_remove]

    unless ns_for_remove.blank?
      ns_for_remove.each do |nameserver|
        partner_configuration= partner.partner_configurations.where("value = ?", nameserver).first
        if partner_configuration.destroy
        else
          success = false
        end
      end
    end

    unless ns_for_add.blank?
      ns_for_add.each do |nameserver|
        new_partner_configuration = partner.partner_configurations.new
        new_partner_configuration.config_name = "nameserver"
        new_partner_configuration.value = nameserver
        if new_partner_configuration.save
        else
          success = false
        end
      end
    end
    render json: success
  end
end
