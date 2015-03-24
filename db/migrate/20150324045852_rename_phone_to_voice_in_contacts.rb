class RenamePhoneToVoiceInContacts < ActiveRecord::Migration
  def change
    rename_column :contacts, :phone, :voice
    rename_column :contact_history, :phone, :voice
  end
end
