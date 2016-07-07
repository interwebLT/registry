require 'rails_helper'

RSpec.describe Powerdns::Record, type: :model do
  describe 'create a new record' do
    let(:pdns_record) {FactoryGirl.build(:powerdns_record)}

    it 'should be a valid record' do
      expect(pdns_record).to be_valid
    end

    it 'is invalid without name' do
      record = FactoryGirl.build(:powerdns_record, name: nil)
      expect(record).not_to be_valid
    end

    it 'is invalid without type' do
      record = FactoryGirl.build(:powerdns_record, type: nil)
      expect(record).not_to be_valid
    end

    it 'is invalid without priority' do
      record = FactoryGirl.build(:powerdns_record, prio: nil)
      expect(record).not_to be_valid
    end
  end

  describe 'when validating name and content' do
    it 'should have a DOMAIN Format name for all types' do
      record = FactoryGirl.build(:powerdns_record, name: 'samplecom')
      expect(record).not_to be_valid
    end

    it 'should have a SUBDOMAIN name for NS type' do
      record = FactoryGirl.build(:powerdns_record, name: 'sample.com', type: 'NS')
      expect(record).not_to be_valid
    end

    it 'should have a DOMAIN format content for NS type' do
      record = FactoryGirl.build(:powerdns_record, content: 'sample', type: 'NS')
      expect(record).not_to be_valid
    end

    it 'should have an IP ADDRESS format content for A type' do
      record = FactoryGirl.build(:powerdns_record, content: 'aaa.168.1.1', type: 'A')
      expect(record).not_to be_valid
    end

    it 'should have an IPv6 format content for AAAA type' do
      record = FactoryGirl.build(:powerdns_record, content: '0000:0000', type: 'AAAA')
      expect(record).not_to be_valid
    end

    it 'should have a DOMAIN format content for CNAME type' do
      record = FactoryGirl.build(:powerdns_record, content: 'notdomaincom', type: 'CNAME')
      expect(record).not_to be_valid
    end

    it 'should have a PRINTABLE ASCII format content for TXT type' do
      record = FactoryGirl.build(:powerdns_record, content: '東京とうきょうトウキョウ', type: 'TXT')
      expect(record).not_to be_valid
    end

    it 'should have a DOMAIN format srv_content for SRV type' do
      record = FactoryGirl.build(:powerdns_record, type: 'SRV', preferences: {srv_content: "sample"})
      expect(record).not_to be_valid
    end
  end
end
