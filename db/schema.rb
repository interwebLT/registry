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

ActiveRecord::Schema.define(version: 20161201045248) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "dblink"
  enable_extension "hstore"
  enable_extension "tablefunc"

  create_table "applications", force: :cascade do |t|
    t.integer "partner_id",            null: false
    t.string  "token",      limit: 32, null: false
    t.string  "client",     limit: 16, null: false
  end

  create_table "authorizations", force: :cascade do |t|
    t.string   "token",              limit: 32, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "user_id"
    t.datetime "last_authorized_at",            null: false
    t.integer  "partner_id",                    null: false
  end

  create_table "blacklists", force: :cascade do |t|
    t.integer  "domain_id",       null: false
    t.integer  "suspended_by",    null: false
    t.datetime "suspend_date",    null: false
    t.text     "suspend_reason"
    t.integer  "activated_by"
    t.datetime "activate_date"
    t.text     "activate_reason"
  end

  create_table "contact_history", force: :cascade do |t|
    t.datetime "created_at",                      default: "now()", null: false
    t.string   "handle",             limit: 16,                     null: false
    t.integer  "partner_id",                                        null: false
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
    t.datetime "updated_at",                                        null: false
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

  create_table "credit_card_payments", force: :cascade do |t|
    t.integer  "eu_transaction_id"
    t.integer  "reg_transaction_id"
    t.datetime "create_date",                                            default: "now()", null: false
    t.decimal  "amount",                        precision: 20, scale: 2,                   null: false
    t.string   "currency",           limit: 5,                                             null: false
    t.string   "ccstatus",           limit: 50,                                            null: false
    t.datetime "ccapprovaldate"
    t.string   "ccinvoice",          limit: 50,                                            null: false
    t.string   "ccrefno",            limit: 50,                                            null: false
    t.string   "ccsource",           limit: 50,                                            null: false
    t.string   "ccapproval",         limit: 50,                                            null: false
    t.string   "ccbatchno",          limit: 50,                                            null: false
    t.text     "ccremarks"
    t.text     "domains"
    t.integer  "invoicerefkey"
    t.integer  "ccpaymentrefkey"
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

  create_table "deleted_services", force: :cascade do |t|
    t.integer  "service_id",              null: false
    t.integer  "domain_id",               null: false
    t.string   "service_type", limit: 30, null: false
    t.string   "status",       limit: 10, null: false
    t.datetime "create_date",             null: false
    t.datetime "last_update"
    t.datetime "expiry_date",             null: false
    t.datetime "delete_date"
  end

  create_table "deleted_webhosting", force: :cascade do |t|
    t.integer  "product_id",                     null: false
    t.integer  "plan_id",                        null: false
    t.integer  "handle"
    t.string   "username",           limit: 255, null: false
    t.string   "server_ip",          limit: 20,  null: false
    t.string   "panel_ip",           limit: 20,  null: false
    t.integer  "monthly_duration",               null: false
    t.string   "status",             limit: 10,  null: false
    t.datetime "create_date",                    null: false
    t.datetime "last_update"
    t.datetime "expiry_date",                    null: false
    t.datetime "delete_date"
    t.datetime "actual_delete_date",             null: false
  end

  create_table "dns", force: :cascade do |t|
    t.integer  "domain_id",                               null: false
    t.text     "name",                                    null: false
    t.string   "dns_type",    limit: 5,                   null: false
    t.integer  "ttl",                                     null: false
    t.integer  "prio"
    t.text     "content",                                 null: false
    t.boolean  "hidden",                default: false,   null: false
    t.boolean  "editable",              default: true,    null: false
    t.boolean  "system",                default: false,   null: false
    t.datetime "create_date",           default: "now()", null: false
    t.boolean  "dotphns",               default: false
  end

  create_table "dns_logs", force: :cascade do |t|
    t.string   "action",      limit: 1,                     null: false
    t.integer  "domain_id",                                 null: false
    t.text     "name",                                      null: false
    t.string   "dns_type",    limit: 5,                     null: false
    t.integer  "ttl",                                       null: false
    t.integer  "prio"
    t.text     "content",                                   null: false
    t.boolean  "hidden",                  default: false,   null: false
    t.boolean  "editable",                default: true,    null: false
    t.boolean  "system",                  default: false,   null: false
    t.datetime "create_date",                               null: false
    t.string   "username",    limit: 255
    t.string   "ip",          limit: 20
    t.datetime "log_date",                default: "now()", null: false
  end

  create_table "dns_sets", force: :cascade do |t|
    t.string  "service",   limit: 50, null: false
    t.string  "subdomain", limit: 64, null: false
    t.string  "dns_type",  limit: 5,  null: false
    t.text    "content"
    t.integer "ttl"
    t.integer "prio"
  end

  create_table "domain_activity", force: :cascade do |t|
    t.datetime "activity_at",       default: "now()", null: false
    t.integer  "partner_id",                          null: false
    t.text     "details"
    t.string   "registrant_handle"
    t.string   "authcode"
    t.datetime "expires_at"
    t.integer  "domain_id"
    t.string   "type",                                null: false
    t.string   "property_changed"
    t.string   "old_value"
    t.string   "value"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "domain_hosts", force: :cascade do |t|
    t.integer  "product_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.text     "ip_list"
  end

  create_table "domain_private_registrations", force: :cascade do |t|
    t.integer  "domain_id"
    t.integer  "partner_id"
    t.string   "registrant_handle"
    t.boolean  "private",           default: false
    t.datetime "registered_at"
    t.datetime "expires_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "domain_search_logs", force: :cascade do |t|
    t.string   "name",       limit: 128, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "domain_status", id: false, force: :cascade do |t|
    t.integer "domain_id",            null: false
    t.string  "status",    limit: 50, null: false
  end

  create_table "domain_transfers", force: :cascade do |t|
    t.integer  "domain_id",                                      null: false
    t.integer  "losing_registrar",                               null: false
    t.integer  "gaining_registrar",                              null: false
    t.string   "authcode",          limit: 64,                   null: false
    t.string   "ip_address",        limit: 20,                   null: false
    t.integer  "source_id"
    t.string   "status",            limit: 10,                   null: false
    t.datetime "create_date",                  default: "now()", null: false
    t.datetime "last_update"
    t.datetime "approve_date"
  end

  create_table "domains", force: :cascade do |t|
    t.integer  "product_id",                                               null: false
    t.integer  "partner_id",                                               null: false
    t.string   "name",                       limit: 128,                   null: false
    t.string   "extension",                  limit: 10
    t.string   "authcode",                   limit: 64,                    null: false
    t.datetime "created_at",                             default: "now()", null: false
    t.datetime "updated_at",                                               null: false
    t.datetime "expires_at",                                               null: false
    t.string   "registrant_handle",          limit: 16,                    null: false
    t.string   "admin_handle",               limit: 16
    t.string   "tech_handle",                limit: 16
    t.string   "billing_handle",             limit: 16
    t.datetime "registered_at",                                            null: false
    t.boolean  "ok",                                     default: false,   null: false
    t.boolean  "inactive",                               default: true,    null: false
    t.boolean  "client_hold",                            default: false,   null: false
    t.boolean  "client_delete_prohibited",               default: false,   null: false
    t.boolean  "client_renew_prohibited",                default: false,   null: false
    t.boolean  "client_transfer_prohibited",             default: false,   null: false
    t.boolean  "client_update_prohibited",               default: false,   null: false
    t.boolean  "server_hold",                            default: false,   null: false
    t.boolean  "server_delete_prohibited",               default: false,   null: false
    t.boolean  "server_renew_prohibited",                default: false,   null: false
    t.boolean  "server_transfer_prohibited",             default: false,   null: false
    t.boolean  "server_update_prohibited",               default: false,   null: false
    t.string   "status_pending_transfer"
  end

  create_table "exchange_rates", id: false, force: :cascade do |t|
    t.integer  "id"
    t.date     "from_date"
    t.date     "to_date"
    t.decimal  "usd_rate"
    t.string   "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  add_index "host_addresses", ["host_id"], name: "index_host_addresses_on_host_id", using: :btree

  create_table "hosts", force: :cascade do |t|
    t.integer  "partner_id",             null: false
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "ledger", force: :cascade do |t|
    t.integer  "partner_id",                                   null: false
    t.integer  "order_id"
    t.decimal  "credits"
    t.string   "activity_type",   limit: 10,                   null: false
    t.datetime "created_at",                 default: "now()", null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "amount_cents",               default: 0,       null: false
    t.string   "amount_currency",            default: "USD",   null: false
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

  create_table "nameserver_ips", force: :cascade do |t|
    t.integer  "nameserver_id",             null: false
    t.string   "handle",        limit: 100
    t.string   "ip_type",       limit: 4,   null: false
    t.string   "ip",            limit: 100, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "client_hold",                default: false, null: false
    t.boolean  "client_delete_prohibited",   default: false, null: false
    t.boolean  "client_renew_prohibited",    default: false, null: false
    t.boolean  "client_transfer_prohibited", default: false, null: false
    t.boolean  "client_update_prohibited",   default: false, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "ok",                         default: false, null: false
    t.boolean  "inactive",                   default: false, null: false
  end

  create_table "old_deleted_domains", force: :cascade do |t|
    t.integer  "domain_id",                     null: false
    t.integer  "old_id"
    t.integer  "registrar_id",                  null: false
    t.integer  "product_id",                    null: false
    t.string   "name",               limit: 64, null: false
    t.string   "extension",          limit: 10, null: false
    t.string   "bought_from"
    t.string   "nsset",              limit: 20, null: false
    t.boolean  "rgp",                           null: false
    t.string   "authcode",           limit: 64, null: false
    t.datetime "create_date",                   null: false
    t.datetime "last_update"
    t.datetime "expiry_date",                   null: false
    t.datetime "delete_date"
    t.string   "registrant_handle",  limit: 16, null: false
    t.string   "admin_handle",       limit: 16
    t.string   "technical_handle",   limit: 16
    t.string   "billing_handle",     limit: 16
    t.datetime "actual_delete_date",            null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer  "order_id",                                             null: false
    t.integer  "product_id"
    t.integer  "period"
    t.string   "status",                   limit: 16,                  null: false
    t.string   "domain",                   limit: 255
    t.string   "registrant_handle",        limit: 16
    t.string   "type",                     limit: 64,                  null: false
    t.integer  "credits_cents",                        default: 0
    t.string   "credits_currency",         limit: 3,   default: "USD"
    t.integer  "price_cents",                          default: 0,     null: false
    t.string   "price_currency",           limit: 3,   default: "USD", null: false
    t.datetime "renewed_at"
    t.datetime "registered_at"
    t.datetime "expires_at"
    t.string   "authcode",                 limit: 64
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "refunded_order_detail_id"
    t.string   "remarks",                              default: ""
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "partner_id",                                        null: false
    t.string   "status",               limit: 16,                   null: false
    t.datetime "created_at",                      default: "now()", null: false
    t.datetime "updated_at",                                        null: false
    t.datetime "completed_at"
    t.integer  "total_price_cents",               default: 0,       null: false
    t.string   "total_price_currency", limit: 3,  default: "USD",   null: false
    t.integer  "fee_cents",                       default: 0,       null: false
    t.string   "fee_currency",         limit: 3,  default: "USD",   null: false
    t.string   "order_number"
    t.datetime "ordered_at",                                        null: false
  end

  add_index "orders", ["order_number"], name: "index_orders_on_order_number", unique: true, using: :btree

  create_table "partner_configurations", force: :cascade do |t|
    t.integer  "partner_id",                                null: false
    t.string   "config_name", limit: 255,                   null: false
    t.text     "value",                                     null: false
    t.datetime "created_at",              default: "now()", null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "partner_pricing", force: :cascade do |t|
    t.integer  "partner_id",                                  null: false
    t.string   "action",         limit: 16,                   null: false
    t.integer  "period",                                      null: false
    t.datetime "created_at",                default: "now()", null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "price_cents",               default: 0,       null: false
    t.string   "price_currency",            default: "USD",   null: false
  end

  create_table "partners", force: :cascade do |t|
    t.integer  "old_id"
    t.string   "name",                limit: 64,                     null: false
    t.string   "encrypted_password",  limit: 255,                    null: false
    t.string   "representative",      limit: 255,                    null: false
    t.string   "organization",        limit: 255,                    null: false
    t.string   "position",            limit: 255,                    null: false
    t.string   "street",              limit: 255,                    null: false
    t.string   "city",                limit: 255,                    null: false
    t.string   "state",               limit: 255,                    null: false
    t.string   "postal_code",         limit: 255,                    null: false
    t.string   "country_code",        limit: 255,                    null: false
    t.string   "nature",              limit: 255,                    null: false
    t.string   "email",               limit: 2048,                   null: false
    t.string   "url",                 limit: 255,                    null: false
    t.string   "voice",               limit: 64,                     null: false
    t.string   "fax",                 limit: 64
    t.string   "public_organization", limit: 255
    t.string   "public_nature",       limit: 255
    t.string   "public_url",          limit: 255
    t.text     "public_street"
    t.string   "public_city",         limit: 50
    t.string   "public_state",        limit: 50
    t.string   "public_postal_code",  limit: 10
    t.string   "public_country_code", limit: 3
    t.string   "public_email",        limit: 255
    t.string   "public_voice",        limit: 32
    t.string   "public_fax",          limit: 32
    t.boolean  "local",                            default: true,    null: false
    t.datetime "created_at",                       default: "now()", null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "admin",                            default: false,   null: false
    t.boolean  "staff",                            default: false,   null: false
    t.string   "salt",                limit: 255,                    null: false
    t.hstore   "preferences"
    t.boolean  "epp_partner",                      default: false
  end

  add_index "partners", ["name"], name: "index_partners_on_name", unique: true, using: :btree
  add_index "partners", ["preferences"], name: "index_partners_on_preferences", using: :gist

  create_table "payment_paypal", id: false, force: :cascade do |t|
    t.integer  "tranid"
    t.datetime "paymentdate"
    t.string   "userid"
    t.string   "receiptnum"
    t.decimal  "amount"
    t.string   "orderdetails"
    t.string   "partner"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "partner_id",                 null: false
    t.integer  "order_id",                   null: false
    t.float    "amount",                     null: false
    t.string   "currency_code",  limit: 5,   null: false
    t.float    "forex"
    t.datetime "posted_at"
    t.string   "bank",           limit: 100
    t.string   "check_number",   limit: 50
    t.string   "account_number", limit: 50
    t.date     "check_date"
    t.string   "payment_type",   limit: 20
    t.text     "request"
    t.text     "remarks"
    t.text     "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "powerdns_domains", force: :cascade do |t|
    t.integer  "domain_id",                   null: false
    t.integer  "notified_serial", default: 1, null: false
    t.string   "name",                        null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "powerdns_records", force: :cascade do |t|
    t.integer  "powerdns_domain_id",                             null: false
    t.string   "name",               limit: 255,                 null: false
    t.string   "type",               limit: 10,                  null: false
    t.text     "content"
    t.integer  "ttl",                            default: 14400
    t.integer  "prio"
    t.integer  "change_date"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.hstore   "preferences"
    t.datetime "end_date"
    t.boolean  "active"
    t.datetime "start_date"
  end

  add_index "powerdns_records", ["name"], name: "index_powerdns_records_on_name", using: :btree
  add_index "powerdns_records", ["preferences"], name: "index_powerdns_records_on_preferences", using: :gist

  create_table "products", force: :cascade do |t|
    t.string "product_type", limit: 20, null: false
  end

  create_table "registrar_applications", force: :cascade do |t|
    t.string   "login_id",        limit: 30,                    null: false
    t.string   "representative",  limit: 255,                   null: false
    t.string   "company",         limit: 255,                   null: false
    t.string   "position",        limit: 255,                   null: false
    t.text     "street1",                                       null: false
    t.text     "street2"
    t.string   "city",            limit: 50
    t.string   "province_state",  limit: 50
    t.string   "postal_code",     limit: 10
    t.string   "country_code",    limit: 3,                     null: false
    t.string   "business_nature", limit: 255,                   null: false
    t.string   "email",           limit: 255
    t.string   "url",             limit: 255
    t.string   "voice",           limit: 32
    t.string   "voice_ext",       limit: 10
    t.string   "fax",             limit: 32
    t.string   "status",          limit: 10,                    null: false
    t.string   "website",         limit: 20
    t.integer  "updated_by"
    t.datetime "create_date",                 default: "now()", null: false
    t.datetime "last_update"
  end

  create_table "registrar_pricing_history", force: :cascade do |t|
    t.string   "operation",              limit: 1,                            null: false
    t.datetime "audit_date"
    t.integer  "reg_pricing_id"
    t.integer  "registrar_id"
    t.integer  "extension_id"
    t.integer  "pricing_category_id"
    t.string   "particular",             limit: 255
    t.decimal  "duration_frequency",                 precision: 20, scale: 2
    t.string   "duration_unit",          limit: 20
    t.decimal  "cost",                               precision: 20, scale: 2
    t.string   "status",                 limit: 10
    t.datetime "effectivity_start_date"
    t.datetime "effectivity_end_date"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "create_date"
    t.datetime "last_update"
  end

  create_table "services", force: :cascade do |t|
    t.integer  "domain_id",                                 null: false
    t.string   "service_type", limit: 30,                   null: false
    t.string   "status",       limit: 10,                   null: false
    t.datetime "create_date",             default: "now()", null: false
    t.datetime "last_update",             default: "now()"
    t.datetime "expiry_date",                               null: false
  end

  create_table "sinag_partners", id: false, force: :cascade do |t|
    t.string  "name",            limit: 255, null: false
    t.integer "troy_partner_id",             null: false
  end

  create_table "transaction_actions", force: :cascade do |t|
    t.integer "pricing_category_id",            default: 1, null: false
    t.string  "action",              limit: 50,             null: false
    t.string  "action_type",         limit: 10,             null: false
  end

  create_table "troy_credit_available", id: false, force: :cascade do |t|
    t.integer  "creditavailablerefkey"
    t.integer  "invoicerefkey"
    t.string   "receiptnum"
    t.integer  "userrefkey"
    t.boolean  "active"
    t.decimal  "amount"
    t.datetime "expiry_date"
    t.string   "created_by"
    t.decimal  "numcredits"
    t.decimal  "unit_cost"
  end

  create_table "troy_deleted_domains", force: :cascade do |t|
    t.string   "domainrefkey"
    t.integer  "primaryuser"
    t.integer  "partnerrefkey"
    t.string   "domain_name"
    t.datetime "deletedate"
  end

  create_table "troy_report_data", id: false, force: :cascade do |t|
    t.integer  "id"
    t.integer  "creditavailablerefkey"
    t.datetime "ordered_at"
    t.integer  "year"
    t.integer  "month"
    t.string   "partner"
    t.string   "order_number"
    t.string   "type"
    t.integer  "amount_cents"
    t.string   "amount_currency"
    t.integer  "period"
    t.string   "domain"
  end

  create_table "troy_report_migration_errors", force: :cascade do |t|
    t.string   "troy_order_number"
    t.string   "affecting_order_number"
    t.text     "log_description"
    t.text     "domain"
    t.string   "source"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
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

  create_table "vas_order_details", force: :cascade do |t|
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
    t.datetime "expires_at"
    t.string   "authcode",                 limit: 64
    t.integer  "refunded_order_detail_id"
    t.string   "remarks",                              default: ""
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "vas_order_id"
  end

  create_table "vas_orders", force: :cascade do |t|
    t.integer  "partner_id",                                      null: false
    t.string   "status",               limit: 16,                 null: false
    t.integer  "total_price_cents",               default: 0,     null: false
    t.string   "total_price_currency", limit: 3,  default: "USD", null: false
    t.integer  "fee_cents",                       default: 0,     null: false
    t.string   "fee_currency",         limit: 3,  default: "USD", null: false
    t.datetime "completed_at"
    t.string   "order_number"
    t.datetime "ordered_at",                                      null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "web_forwarding", force: :cascade do |t|
    t.integer "service_id",                              null: false
    t.text    "title",                                   null: false
    t.string  "url",         limit: 255,                 null: false
    t.text    "keywords"
    t.text    "description"
    t.boolean "frame",                   default: false, null: false
  end

  create_table "zone_override", id: false, force: :cascade do |t|
    t.string  "content",   limit: 255
    t.integer "ttl"
    t.text    "prio"
    t.string  "type",      limit: 6
    t.integer "domain_id"
    t.string  "name",      limit: 255
  end

  add_foreign_key "host_addresses", "hosts"
end
