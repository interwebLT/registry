class MigrateDomainActivityToObjectActivity < ActiveRecord::Migration
  def change
    DomainActivity::Registered.all.each { |activity| migrate_create activity }
    DomainActivity::Updated.all.each    { |activity| migrate_update activity }
  end

  def migrate_create activity
    ObjectActivity::Create.create!  partner:  activity.partner,
                                    product:  activity.domain.product,
                                    activity_at:  activity.activity_at,
                                    registrant_handle:  activity.registrant_handle,
                                    authcode: activity.authcode,
                                    expires_at: activity.expires_at
  end

  def migrate_update activity
    ObjectActivity::Update.create!  partner:  activity.partner,
                                    product:  activity.domain.product,
                                    activity_at:  activity.activity_at,
                                    property_changed: activity.property_changed,
                                    old_value:  activity.old_value,
                                    value:  activity.value
  end
end
