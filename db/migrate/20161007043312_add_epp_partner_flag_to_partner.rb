class AddEppPartnerFlagToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :epp_partner, :boolean, default: false
  end
end
