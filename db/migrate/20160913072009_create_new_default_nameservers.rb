class CreateNewDefaultNameservers < ActiveRecord::Migration
  def change
    Nameserver.all.delete_all
    Nameserver.create name: "ns5.domains.ph"
    Nameserver.create name: "ns6.domains.ph"
  end
end
