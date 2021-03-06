class Cocca::Domain < ActiveRecord::Base
  establish_connection :public_cocca_db
  self.table_name = 'domain'

  before_save :create_audit_master_entry

  def self.get_transaction_id_seq
    Cocca::Domain.connection.select_value("select last_value from audit.transaction_id_seq")
    current_sequence = Cocca::Domain.connection.select_value("SELECT nextval('audit.transaction_id_seq'::regclass)")

    current_sequence
  end

  private

  def create_audit_master_entry
    transaction_id_seq             = Cocca::Domain.get_transaction_id_seq
    cocca_master                   = Cocca::Master.new
    cocca_master.audit_transaction = transaction_id_seq
    cocca_master.audit_user        = "Rails Rake Task"
    cocca_master.audit_login       = "API"
    cocca_master.audit_time        = Time.now
    cocca_master.audit_ip          = "172.16.47.53"
    cocca_master.save!
  end
end