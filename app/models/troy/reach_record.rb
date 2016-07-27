class Troy::ReachRecord < ActiveRecord::Base
  establish_connection :troy

  self.table_name = 'reach_records'
  self.inheritance_column = :_type_disabled

  belongs_to :domain, foreign_key: 'domain_id'

  def to_hash
    {
      :name => name,
      :type => type,
      :content => content,
      :ttl => ttl,
      :priority => prio,
      :startdate => startdate,
      :expirydate => expirydate
    }
  end
end
