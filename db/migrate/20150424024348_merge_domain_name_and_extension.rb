class MergeDomainNameAndExtension < ActiveRecord::Migration
  def change
    change_column :domains, :name,      :string, null: false, limit: 128
    change_column :domains, :extension, :string, null: true,  limit: 10

    Domain.all.each do |domain|
      domain.name = domain.name + domain.extension
      domain.save!
    end
  end
end
