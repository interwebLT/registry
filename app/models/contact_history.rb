class ContactHistory < ActiveRecord::Base
  self.table_name = 'contact_history'

  belongs_to :contact, foreign_key: :handle
  belongs_to :partner
end
