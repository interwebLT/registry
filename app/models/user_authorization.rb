class UserAuthorization < Authorization
  belongs_to :user

  validates :user, presence: true
end
