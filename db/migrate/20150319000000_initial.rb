class Initial < ActiveRecord::Migration
  def change
    create_table :authorizations, force: :cascade do |t|
      t.string   :token,      limit: 32, null: false
      t.integer  :user_id,               null: false

      t.timestamps null: false
    end

    create_table :contact_history, force: :cascade do |t|
      t.string   :handle,       limit: 16,   null: false
      t.integer  :partner_id,                null: false
      t.string   :name,         limit: 255
      t.string   :email,        limit: 2048
      t.string   :organization, limit: 255
      t.string   :phone,        limit: 64
      t.string   :fax,          limit: 64
      t.string   :street,       limit: 255
      t.string   :city,         limit: 255
      t.string   :state,        limit: 255
      t.string   :country_code, limit: 255
      t.string   :postal_code,  limit: 255

      t.timestamps null: false
    end

    create_table :contacts, id: false, force: :cascade do |t|
      t.string   :handle,       limit: 16,   null: false
      t.integer  :partner_id,                null: false
      t.string   :name,         limit: 255
      t.string   :email,        limit: 2048
      t.string   :organization, limit: 255
      t.string   :phone,        limit: 64
      t.string   :fax,          limit: 64
      t.string   :street,       limit: 255
      t.string   :city,         limit: 255
      t.string   :state,        limit: 255
      t.string   :country_code, limit: 255
      t.string   :postal_code,  limit: 255

      t.timestamps null: false
    end

    create_table :domain_activity, force: :cascade do |t|
      t.integer   :partner_id,        null: false
      t.timestamp :activity_at,       null: false
      t.string    :type,              null: false
      t.integer   :domain_id

      t.text      :details

      t.string    :registrant_handle
      t.string    :authcode
      t.datetime  :expires_at

      t.string    :property_changed
      t.string    :old_value
      t.string    :value

      t.timestamps null: false
    end

    create_table :domain_hosts, force: :cascade do |t|
      t.integer  :product_id,             null: false
      t.string   :name,       limit: 255, null: false

      t.timestamps null: false
    end

    create_table :domains, force: :cascade do |t|
      t.integer   :product_id,                   null: false
      t.integer   :partner_id,                   null: false
      t.string    :name,              limit: 64, null: false
      t.string    :extension,         limit: 10, null: false
      t.string    :authcode,          limit: 64, null: false
      t.timestamp :registered_at,                null: false
      t.timestamp :expires_at,                   null: false
      t.string    :registrant_handle, limit: 16, null: false
      t.string    :admin_handle,      limit: 16
      t.string    :tech_handle,       limit: 16
      t.string    :billing_handle,    limit: 16

      t.timestamps null: false
    end

    create_table :host_addresses, force: :cascade do |t|
      t.integer  :host_id,                null: false
      t.string   :address,    limit: 255, null: false
      t.string   :type,       limit: 2,   null: false

      t.timestamps null: false
    end

    create_table :hosts, force: :cascade do |t|
      t.integer  :partner_id,             null: false
      t.string   :name,       limit: 255, null: false

      t.timestamps null: false
    end

    create_table :ledger, force: :cascade do |t|
      t.integer  :partner_id,                                        null: false
      t.integer  :order_id,                                          null: false
      t.decimal  :credits,                  precision: 20, scale: 2, null: false
      t.string   :activity_type, limit: 10,                          null: false

      t.timestamps null: false
    end

    create_table :object_status_history, force: :cascade do |t|
      t.integer  :object_status_id,           null: false
      t.boolean  :ok,                         null: false
      t.boolean  :inactive,                   null: false
      t.boolean  :client_hold,                null: false
      t.boolean  :client_delete_prohibited,   null: false
      t.boolean  :client_renew_prohibited,    null: false
      t.boolean  :client_transfer_prohibited, null: false
      t.boolean  :client_update_prohibited,   null: false

      t.timestamps null: false
    end

    create_table :object_statuses, force: :cascade do |t|
      t.integer  :product_id,                                 null: false
      t.boolean  :ok,                         default: false, null: false
      t.boolean  :inactive,                   default: false, null: false
      t.boolean  :client_hold,                default: false, null: false
      t.boolean  :client_delete_prohibited,   default: false, null: false
      t.boolean  :client_renew_prohibited,    default: false, null: false
      t.boolean  :client_transfer_prohibited, default: false, null: false
      t.boolean  :client_update_prohibited,   default: false, null: false

      t.timestamps null: false
    end

    create_table :order_details, force: :cascade do |t|
      t.integer   :order_id,                                      null: false
      t.integer   :product_id
      t.string    :type,              limit: 64,                  null: false
      t.integer   :price_cents,                   default: 0,     null: false
      t.string    :price_currency,    limit: 3,   default: 'USD', null: false
      t.string    :status,            limit: 16,                  null: false

      t.string    :domain,            limit: 255
      t.integer   :period

      t.string    :registrant_handle, limit: 16
      t.timestamp :registered_at

      t.timestamp :renewed_at

      t.integer   :credits_cents,                 default: 0
      t.string    :credits_currency,  limit: 3,   default: 'USD'

      t.timestamps null: false
    end

    create_table :orders, force: :cascade do |t|
      t.integer   :partner_id,                                      null: false
      t.string    :status,               limit: 16,                 null: false
      t.integer   :total_price_cents,               default: 0,     null: false
      t.string    :total_price_currency, limit: 3,  default: 'USD', null: false
      t.integer   :fee_cents,                       default: 0,     null: false
      t.string    :fee_currency,         limit: 3,  default: 'USD', null: false
      t.timestamp :completed_at

      t.timestamps null: false
    end

    create_table :partner_configurations, force: :cascade do |t|
      t.integer  :partner_id,              null: false
      t.string   :config_name, limit: 255, null: false
      t.text     :value,                   null: false

      t.timestamps null: false
    end

    create_table :partner_pricing, force: :cascade do |t|
      t.integer  :partner_id,                                null: false
      t.string   :action,         limit: 16,                 null: false
      t.integer  :period,                                    null: false
      t.integer  :price_cents,               default: 0,     null: false
      t.string   :price_currency,            default: 'USD', null: false

      t.timestamps null: false
    end

    create_table :partners, force: :cascade do |t|
      t.integer  :old_id
      t.string   :name,                limit: 64,                   null: false
      t.string   :encrypted_password,  limit: 255,                  null: false
      t.string   :representative,      limit: 255,                  null: false
      t.string   :position,            limit: 255,                  null: false
      t.string   :organization,        limit: 255,                  null: false
      t.string   :nature,              limit: 255,                  null: false
      t.string   :url,                 limit: 255,                  null: false
      t.string   :street,              limit: 255,                  null: false
      t.string   :city,                limit: 255,                  null: false
      t.string   :state,               limit: 255,                  null: false
      t.string   :postal_code,         limit: 255,                  null: false
      t.string   :country_code,        limit: 255,                  null: false
      t.string   :email,               limit: 2048,                 null: false
      t.string   :voice,               limit: 64,                   null: false
      t.string   :fax,                 limit: 64
      t.string   :public_organization, limit: 255
      t.string   :public_nature,       limit: 255
      t.string   :public_url,          limit: 255
      t.string   :public_street,       limit: 255
      t.string   :public_city,         limit: 255
      t.string   :public_state,        limit: 255
      t.string   :public_postal_code,  limit: 255
      t.string   :public_country_code, limit: 255
      t.string   :public_email,        limit: 2048
      t.string   :public_voice,        limit: 64
      t.string   :public_fax,          limit: 64
      t.boolean  :local,                            default: true,  null: false
      t.boolean  :admin,                            default: false, null: false
      t.boolean  :staff,                            default: false, null: false

      t.timestamps null: false
    end

    create_table :products, force: :cascade do |t|
      t.string :product_type, limit: 20, null: false
    end
  end
end
