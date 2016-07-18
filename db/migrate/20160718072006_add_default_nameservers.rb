class AddDefaultNameservers < ActiveRecord::Migration
  def change
    Nameserver.create name: "nsfwd.domains.ph"
    Nameserver.create name: "ns2.domains.ph"
  end
end