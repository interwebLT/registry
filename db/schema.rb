# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160718072006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "applications", force: :cascade do |t|
    t.integer "partner_id",            null: false
    t.string  "token",      limit: 32, null: false
    t.string  "client",     limit: 16, null: false
  end

  create_table "authorizations", force: :cascade do |t|
    t.string   "token",              limit: 32, null: false
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "last_authorized_at",            null: false
    t.integer  "partner_id",                    null: false
  end

  create_table "contact_history", force: :cascade do |t|
    t.string   "handle",             limit: 16,   null: false
    t.integer  "partner_id",                      null: false
    t.string   "name",               limit: 255
    t.string   "email",              limit: 2048
    t.string   "organization",       limit: 255
    t.string   "voice",              limit: 64
    t.string   "fax",                limit: 64
    t.string   "street",             limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "country_code",       limit: 255
    t.string   "postal_code",        limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "street2",            limit: 255
    t.string   "street3",            limit: 255
    t.string   "voice_ext",          limit: 64
    t.string   "fax_ext",            limit: 64
    t.string   "local_name",         limit: 255
    t.string   "local_organization", limit: 255
    t.string   "local_street",       limit: 255
    t.string   "local_street2",      limit: 255
    t.string   "local_street3",      limit: 255
    t.string   "local_city",         limit: 255
    t.string   "local_state",        limit: 255
    t.string   "local_postal_code",  limit: 255
    t.string   "local_country_code", limit: 255
  end

  create_table "contacts", id: false, force: :cascade do |t|
    t.string   "handle",             limit: 16,   null: false
    t.integer  "partner_id",                      null: false
    t.string   "name",               limit: 255
    t.string   "email",              limit: 2048
    t.string   "organization",       limit: 255
    t.string   "voice",              limit: 64
    t.string   "fax",                limit: 64
    t.string   "street",             limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "country_code",       limit: 255
    t.string   "postal_code",        limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "street2",            limit: 255
    t.string   "street3",            limit: 255
    t.string   "voice_ext",          limit: 64
    t.string   "fax_ext",            limit: 64
    t.string   "local_name",         limit: 255
    t.string   "local_organization", limit: 255
    t.string   "local_street",       limit: 255
    t.string   "local_street2",      limit: 255
    t.string   "local_street3",      limit: 255
    t.string   "local_city",         limit: 255
    t.string   "local_state",        limit: 255
    t.string   "local_postal_code",  limit: 255
    t.string   "local_country_code", limit: 255
  end

  create_table "credits", force: :cascade do |t|
    t.integer  "partner_id"
    t.string   "type",              limit: 64,                 null: false
    t.string   "status"
    t.integer  "amount_cents"
    t.string   "amount_currency",   limit: 3,  default: "USD"
    t.string   "verification_code"
    t.string   "remarks"
    t.string   "credit_number"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.datetime "credited_at"
    t.integer  "fee_cents"
    t.string   "fee_currency",      limit: 3,  default: "USD"
  end

  create_table "deleted_domains", force: :cascade do |t|
    t.integer  "product_id",                                             null: false
    t.integer  "partner_id",                                             null: false
    t.string   "name",                       limit: 128,                 null: false
    t.string   "authcode",                   limit: 64,                  null: false
    t.string   "registrant_handle",          limit: 16,                  null: false
    t.string   "admin_handle",               limit: 16
    t.string   "billing_handle",             limit: 16
    t.string   "tech_handle",                limit: 16
    t.datetime "registered_at",                                          null: false
    t.datetime "expires_at",                                             null: false
    t.datetime "deleted_at",                                             null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.integer  "domain_id",                                              null: false
    t.boolean  "ok",                                     default: false, null: false
    t.boolean  "inactive",                               default: true,  null: false
    t.boolean  "client_hold",                            default: false, null: false
    t.boolean  "client_delete_prohibited",               default: false, null: false
    t.boolean  "client_renew_prohibited",                default: false, null: false
    t.boolean  "client_transfer_prohibited",             default: false, null: false
    t.boolean  "client_update_prohibited",               default: false, null: false
  end

  create_table "domain_activity", force: :cascade do |t|
    t.integer  "partner_id",        null: false
    t.datetime "activity_at",       null: false
    t.string   "type",              null: false
    t.integer  "domain_id"
    t.text     "details"
    t.string   "registrant_handle"
    t.string   "authcode"
    t.datetime "expires_at"
    t.string   "property_changed"
    t.string   "old_value"
    t.string   "value"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "domain_hosts", force: :cascade do |t|
    t.integer  "product_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "domain_search_logs", force: :cascade do |t|
    t.string   "name",       limit: 128, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "domains", force: :cascade do |t|
    t.integer  "product_id",                                             null: false
    t.integer  "partner_id",                                             null: false
    t.string   "name",                       limit: 128,                 null: false
    t.string   "extension",                  limit: 10
    t.string   "authcode",                   limit: 64,                  null: false
    t.datetime "registered_at",                                          null: false
    t.datetime "expires_at",                                             null: false
    t.string   "registrant_handle",          limit: 16,                  null: false
    t.string   "admin_handle",               limit: 16
    t.string   "tech_handle",                limit: 16
    t.string   "billing_handle",             limit: 16
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.boolean  "ok",                                     default: false, null: false
    t.boolean  "inactive",                               default: true,  null: false
    t.boolean  "client_hold",                            default: false, null: false
    t.boolean  "client_delete_prohibited",               default: false, null: false
    t.boolean  "client_renew_prohibited",                default: false, null: false
    t.boolean  "client_transfer_prohibited",             default: false, null: false
    t.boolean  "client_update_prohibited",               default: false, null: false
    t.boolean  "server_hold",                            default: false, null: false
    t.boolean  "server_delete_prohibited",               default: false, null: false
    t.boolean  "server_renew_prohibited",                default: false, null: false
    t.boolean  "server_transfer_prohibited",             default: false, null: false
    t.boolean  "server_update_prohibited",               default: false, null: false
  end

  create_table "excluded_partners", force: :cascade do |t|
    t.string   "name",       limit: 16, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "external_registries", force: :cascade do |t|
    t.string "name", limit: 16,  null: false
    t.string "url",  limit: 255, null: false
  end

  create_table "host_addresses", force: :cascade do |t|
    t.integer  "host_id",                null: false
    t.string   "address",    limit: 255, null: false
    t.string   "type",       limit: 2,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "hosts", force: :cascade do |t|
    t.integer  "partner_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ledger", force: :cascade do |t|
    t.integer  "partner_id",                                 null: false
    t.integer  "order_id"
    t.decimal  "credits"
    t.string   "activity_type",   limit: 10,                 null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "amount_cents",               default: 0,     null: false
    t.string   "amount_currency",            default: "USD", null: false
    t.integer  "credit_id"
  end

  create_table "migrated_domains", force: :cascade do |t|
    t.integer  "partner_id",                    null: false
    t.string   "name",              limit: 128, null: false
    t.string   "registrant_handle", limit: 16,  null: false
    t.datetime "registered_at",                 null: false
    t.datetime "expires_at",                    null: false
    t.string   "authcode",                      null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "nameservers", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "object_activities", force: :cascade do |t|
    t.string   "type",              limit: 64,  null: false
    t.integer  "partner_id",                    null: false
    t.integer  "product_id",                    null: false
    t.datetime "activity_at",                   null: false
    t.string   "registrant_handle", limit: 16
    t.string   "authcode",          limit: 64
    t.datetime "expires_at"
    t.string   "property_changed",  limit: 64
    t.string   "old_value",         limit: 255
    t.string   "value",             limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "losing_partner_id"
  end

  create_table "object_status_history", force: :cascade do |t|
    t.integer  "object_status_id",           null: false
    t.boolean  "ok",                         null: false
    t.boolean  "inactive",                   null: false
    t.boolean  "client_hold",                null: false
    t.boolean  "client_delete_prohibited",   null: false
    t.boolean  "client_renew_prohibited",    null: false
    t.boolean  "client_transfer_prohibited", null: false
    t.boolean  "client_update_prohibited",   null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "object_statuses", force: :cascade do |t|
    t.integer  "product_id",                                 null: false
    t.boolean  "ok",                         default: false, null: false
    t.boolean  "inactive",                   default: false, null: false
    t.boolean  "client_hold",                default: false, null: false
    t.boolean  "client_delete_prohibited",   default: false, null: false
    t.boolean  "client_renew_prohibited",    default: false, null: false
    t.boolean  "client_transfer_prohibited", default: false, null: false
    t.boolean  "client_update_prohibited",   default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer  "order_id",                                             null: false
    t.integer  "product_id"
    t.string   "type",                     limit: 64,                  null: false
    t.integer  "price_cents",                          default: 0,     null: false
    t.string   "price_currency",           limit: 3,   default: "USD", null: false
    t.string   "status",                   limit: 16,                  null: false
    t.string   "domain",                   limit: 255
    t.integer  "period"
    t.string   "registrant_handle",        limit: 16
    t.datetime "registered_at"
    t.datetime "renewed_at"
    t.integer  "credits_cents",                        default: 0
    t.string   "credits_currency",         limit: 3,   default: "USD"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.datetime "expires_at"
    t.string   "authcode",                 limit: 64
    t.integer  "refunded_order_detail_id"
    t.string   "remarks",                              default: ""
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "partner_id",                                      null: false
    t.string   "status",               limit: 16,                 null: false
    t.integer  "total_price_cents",               default: 0,     null: false
    t.string   "total_price_currency", limit: 3,  default: "USD", null: false
    t.integer  "fee_cents",                       default: 0,     null: false
    t.string   "fee_currency",         limit: 3,  default: "USD", null: false
    t.datetime "completed_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "order_number"
    t.datetime "ordered_at",                                      null: false
  end

  add_index "orders", ["order_number"], name: "index_orders_on_order_number", unique: true, using: :btree

  create_table "partner_configurations", force: :cascade do |t|
    t.integer  "partner_id",              null: false
    t.string   "config_name", limit: 255, null: false
    t.text     "value",                   null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "partner_pricing", force: :cascade do |t|
    t.integer  "partner_id",                                null: false
    t.string   "action",         limit: 16,                 null: false
    t.integer  "period",                                    null: false
    t.integer  "price_cents",               default: 0,     null: false
    t.string   "price_currency",            default: "USD", null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "partners", force: :cascade do |t|
    t.integer  "old_id"
    t.string   "name",                limit: 64,                   null: false
    t.string   "encrypted_password",  limit: 255,                  null: false
    t.string   "representative",      limit: 255,                  null: false
    t.string   "position",            limit: 255,                  null: false
    t.string   "organization",        limit: 255,                  null: false
    t.string   "nature",              limit: 255,                  null: false
    t.string   "url",                 limit: 255,                  null: false
    t.string   "street",              limit: 255,                  null: false
    t.string   "city",                limit: 255,                  null: false
    t.string   "state",               limit: 255,                  null: false
    t.string   "postal_code",         limit: 255,                  null: false
    t.string   "country_code",        limit: 255,                  null: false
    t.string   "email",               limit: 2048,                 null: false
    t.string   "voice",               limit: 64,                   null: false
    t.string   "fax",                 limit: 64
    t.string   "public_organization", limit: 255
    t.string   "public_nature",       limit: 255
    t.string   "public_url",          limit: 255
    t.string   "public_street",       limit: 255
    t.string   "public_city",         limit: 255
    t.string   "public_state",        limit: 255
    t.string   "public_postal_code",  limit: 255
    t.string   "public_country_code", limit: 255
    t.string   "public_email",        limit: 2048
    t.string   "public_voice",        limit: 64
    t.string   "public_fax",          limit: 64
    t.boolean  "local",                            default: true,  null: false
    t.boolean  "admin",                            default: false, null: false
    t.boolean  "staff",                            default: false, null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "salt",                limit: 255,                  null: false
  end

  add_index "partners", ["name"], name: "index_partners_on_name", unique: true, using: :btree

  create_table "powerdns_domains", force: :cascade do |t|
    t.integer  "domain_id",                   null: false
    t.integer  "notified_serial", default: 1, null: false
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "powerdns_records", force: :cascade do |t|
    t.integer  "powerdns_domain_id",             null: false
    t.string   "name",               limit: 255, null: false
    t.string   "type",               limit: 10,  null: false
    t.text     "content"
    t.integer  "ttl"
    t.integer  "prio"
    t.integer  "change_date"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.hstore   "preferences"
    t.datetime "end_date"
  end

  add_index "powerdns_records", ["name"], name: "index_powerdns_records_on_name", using: :btree
  add_index "powerdns_records", ["preferences"], name: "index_powerdns_records_on_preferences", using: :gist

  create_table "products", force: :cascade do |t|
    t.string "product_type", limit: 20, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string  "email",              limit: 255, null: false
    t.string  "name",               limit: 64,  null: false
    t.string  "salt",               limit: 255, null: false
    t.string  "encrypted_password", limit: 255, null: false
    t.string  "username",           limit: 255
    t.date    "registered_at",                  null: false
    t.integer "partner_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
