class AddVoiceAndFaxExtensions < ActiveRecord::Migration
  def change
    add_column :contacts, :voice_ext, :string, limit: 64
    add_column :contacts, :fax_ext,   :string, limit: 64

    add_column :contact_history, :voice_ext,  :string, limit: 64
    add_column :contact_history, :fax_ext,    :string, limit: 64
  end
end
