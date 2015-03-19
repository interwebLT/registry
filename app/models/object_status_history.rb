class ObjectStatusHistory < ActiveRecord::Base
  self.table_name = 'object_status_history'

  belongs_to :object_status
end
