class RequireTypeInCredits < ActiveRecord::Migration
  def change
    Credit.where(type: nil).each do |credit|
      credit.type = Credit::BankReplenish.to_s
    end

    change_column :credits, :type, :string, null: false, limit: 64
  end
end
