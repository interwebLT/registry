class AddIpListToDomainHost < ActiveRecord::Migration
  def change
    add_column :domain_hosts, :ip_list, :text
  end
end
