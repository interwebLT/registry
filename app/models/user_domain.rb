class UserDomain < ActiveRecord::Base
	belongs_to :user, class_name: User
	belongs_to :domain, class_name: Domain
end
