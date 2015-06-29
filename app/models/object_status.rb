# This class should no longer be actively used. However, it's required so that
# the migrations still work properly.
class ObjectStatus < ActiveRecord::Base
  belongs_to :product
end
