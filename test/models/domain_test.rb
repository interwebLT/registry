require 'test_helper'

describe Domain do
  describe :associations do
    subject { create :domain, name: 'test.ph' }

    before do
      subject.admin_handle = subject.registrant.handle
      subject.billing_handle = subject.registrant.handle
      subject.tech_handle = subject.registrant.handle
      subject.save

      create :object_activity, product: subject.product, type: ObjectActivity::Create
    end

    specify { subject.partner.wont_be_nil }
    specify { subject.product.wont_be_nil }
    specify { subject.registrant.wont_be_nil }
    specify { subject.admin_contact.wont_be_nil }
    specify { subject.billing_contact.wont_be_nil }
    specify { subject.tech_contact.wont_be_nil }
    specify { subject.domain_activities.wont_be_empty }
  end

  describe :zone do
    subject { Domain.new name: "domain#{extension}" }

    let(:extension) { '.ph' }

    specify { subject.zone.must_equal 'ph' }

    context :when_two_level_tld do
      let(:extension) { '.com.ph' }

      specify { subject.zone.must_equal 'com.ph' }
    end
  end

  describe :full_name do
    subject { Domain.new name: 'domain.ph' }

    specify { subject.full_name.must_equal 'domain.ph' }
  end

  describe :available_tlds do
    subject { Domain.available_tlds(domain_name) }

    context :when_all_tlds_available do
      let(:domain_name) { 'available' }

      specify { subject.must_equal ['ph', 'com.ph', 'net.ph', 'org.ph'] }
    end

    context :when_no_tlds_available do
      let(:domain_name) { 'notavailable' }

      before do
        contact = create :contact

        create :domain, registrant: contact, name: 'notavailable.ph'
        create :domain, registrant: contact, name: 'notavailable.com.ph'
        create :domain, registrant: contact, name: 'notavailable.net.ph'
        create :domain, registrant: contact, name: 'notavailable.org.ph'
      end

      specify { subject.must_equal [] }
    end

    context :when_some_tlds_available do
      let(:domain_name) { 'test' }

      before do
        contact = create :contact

        create :domain, registrant: contact, name: 'test.ph'
        create :domain, registrant: contact, name: 'test.com.ph'
      end

      specify { subject.must_equal ['net.ph', 'org.ph'] }
    end
  end

  describe :expired? do
    subject { Domain.new(expires_at: '2014-09-01T00:59:29.777Z'.to_date) }

    specify { subject.expired?('2014-09-01'.to_date).must_equal true }
    specify { subject.expired?('2014-08-31'.to_date).must_equal false }
    specify { subject.expired?('2014-08-31'.to_date).must_equal false }
  end

  describe :expiring? do
    subject { Domain.new(expires_at: '2014-08-31T00:59:29.777Z'.to_date) }

    specify { subject.expiring?('2014-08-01'.to_date).must_equal true }
    specify { subject.expiring?('2014-08-10'.to_date).must_equal true }
    specify { subject.expiring?('2014-09-01'.to_date).must_equal false }
    specify { subject.expiring?('2014-08-31'.to_date).must_equal false }
  end

  describe :named do
    subject { Domain.named(domain_name) }

    context :when_domain_exists do
      before do
        create :domain, name: 'domain.ph'
      end

      let(:domain_name) { 'domain.ph' }

      specify { subject.wont_be_nil }
    end

    context :when_domain_does_not_exist do
      let(:domain_name) { 'domain.com.ph' }

      specify { subject.must_be_nil }
    end

    context :when_domain_has_two_level_tld do
      before do
        create :domain, name: 'domain.com.ph'
      end

      let(:domain_name) { 'domain.com.ph' }

      specify { subject.wont_be_nil }
    end
  end

  describe :valid? do
    subject { build :domain }

    context :when_registrant_handle_missing do
      before do
        subject.registrant_handle = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_registrant_handle_does_not_exist do
      before do
        subject.registrant_handle = 'nonexisting'

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:registrant_handle].must_equal ['invalid'] }
    end

    context :when_admin_handle_missing do
      before do
        subject.admin_handle = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_admin_handle_does_not_exist do
      before do
        subject.admin_handle = 'nonexisting'

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:admin_handle].must_equal ['invalid'] }
    end

    context :when_billing_handle_missing do
      before do
        subject.billing_handle = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_billing_handle_does_not_exist do
      before do
        subject.billing_handle = 'nonexisting'

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:billing_handle].must_equal ['invalid'] }
    end

    context :when_tech_handle_missing do
      before do
        subject.tech_handle = nil

        subject.valid?
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_tech_handle_does_not_exist do
      before do
        subject.tech_handle = 'nonexisting'

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:tech_handle].must_equal ['invalid'] }
    end

    context :when_domain_name_exists do
      before do
        create :domain, name: 'existing.ph', registrant: subject.registrant

        subject.name = 'existing.ph'

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:domain].must_equal ['invalid'] }
    end
  end

  describe :callbacks do
    subject { create :domain, name: 'callbacks', expires_at: expires_at }

    let(:expires_at) { '2015-01-01 00:00'.in_time_zone }
    let(:activities) { subject.domain_activities }
    let(:object_status) { subject.product.object_status }

    context :when_created do
      specify { activities.count.must_equal 1 }
      specify { activities.first.must_be_kind_of ObjectActivity::Create }

      specify { subject.product.domain_hosts.must_be_empty }
    end

    context :expires_at_updated do
      before do
        subject.expires_at = subject.expires_at + 1.year
        subject.save
      end

      specify { activities.count.must_equal 2 }

      specify { activities.last.must_be_kind_of ObjectActivity::Update }
      specify { activities.last.property_changed.must_equal 'expires_at' }
      specify { activities.last.old_value.must_equal expires_at }
      specify { activities.last.value.must_equal (expires_at + 1.year) }
    end

    context :authcode_updated do
      before do
        subject.authcode = 'NEW_AUTHCODE'
        subject.save
      end

      specify { activities.count.must_equal 2 }

      specify { activities.last.must_be_kind_of ObjectActivity::Update }
      specify { activities.last.property_changed.must_equal 'authcode' }
      specify { activities.last.old_value.must_equal 'ABCD123' }
      specify { activities.last.value.must_equal 'NEW_AUTHCODE' }
    end
  end

  describe :renew do
    subject { create :domain, expires_at: '2015-01-01 01:01 AM'.in_time_zone }

    context :when_successful do
      before { subject.renew 2 }
      specify { subject.expires_at.must_equal '2017-01-01 01:01 AM'.in_time_zone }
    end

    context :when_failing do
     specify { proc{ subject.renew 0 }.must_raise RuntimeError }
     specify { proc{ subject.renew -1 }.must_raise RuntimeError }
    end
  end

  describe :update_status do
    subject { create :domain }

    before do
      before_action

      @update_result = subject.update params
    end

    let(:before_action) { }
    let(:update_result) { @update_result }
    let(:object_status) { subject.product.object_status }

    context :when_successful do
      let(:params) {
        {
          client_hold: true,
          client_delete_prohibited: true,
          client_transfer_prohibited: true,
          client_renew_prohibited: true,
          client_update_prohibited: true
        }
      }

      specify { update_result.must_equal true }
      specify { subject.errors.must_be_empty }
      specify { object_status.client_hold.must_equal true }
      specify { object_status.client_delete_prohibited.must_equal true }
      specify { object_status.client_transfer_prohibited.must_equal true }
      specify { object_status.client_renew_prohibited.must_equal true }
      specify { object_status.client_update_prohibited.must_equal true }
    end

    context :when_unset_successful do
      let(:before_action) do
        object_status.client_hold = true
        object_status.client_delete_prohibited = true
        object_status.client_renew_prohibited = true
        object_status.client_transfer_prohibited = true
        object_status.client_update_prohibited = true
        object_status.save
      end

      let(:params) {
        {
          client_hold: false,
          client_delete_prohibited: false,
          client_transfer_prohibited: false,
          client_renew_prohibited: false,
          client_update_prohibited: false
        }
      }

      specify { update_result.must_equal true }
      specify { subject.errors.must_be_empty }
      specify { object_status.client_hold.must_equal false }
      specify { object_status.client_delete_prohibited.must_equal false }
      specify { object_status.client_transfer_prohibited.must_equal false }
      specify { object_status.client_renew_prohibited.must_equal false }
      specify { object_status.client_update_prohibited.must_equal false }
    end

    context :when_client_hold_invalid do
      let(:params) { { client_hold: 'invalid' } }

      specify { update_result.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:client_hold].must_equal ['invalid'] }
      specify { object_status.client_hold.must_equal false }
    end

    context :when_client_delete_prohibited_invalid do
      let(:params) { { client_delete_prohibited: 'invalid' } }

      specify { update_result.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:client_delete_prohibited].must_equal ['invalid'] }
      specify { object_status.client_delete_prohibited.must_equal false }
    end

    context :when_client_renew_prohibited_invalid do
      let(:params) { { client_renew_prohibited: 'invalid' } }

      specify { update_result.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:client_renew_prohibited].must_equal ['invalid'] }
      specify { object_status.client_renew_prohibited.must_equal false }
    end

    context :when_client_transfer_prohibited_invalid do
      let(:params) { { client_transfer_prohibited: 'invalid' } }

      specify { update_result.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:client_transfer_prohibited].must_equal ['invalid'] }
      specify { object_status.client_transfer_prohibited.must_equal false }
    end

    context :when_client_update_prohibited_invalid do
      let(:params) { { client_update_prohibited: 'invalid' } }

      specify { update_result.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:client_update_prohibited].must_equal ['invalid'] }
      specify { object_status.client_update_prohibited.must_equal false }
    end
  end

  describe :latest do
    subject { Domain.latest }

    before do
      contact = create :contact

      create :domain, registered_at: Time.now, registrant: contact, name: 'abc.ph'
      create :domain, registered_at: Time.now, registrant: contact, name: 'def.ph'
      create :domain, registered_at: Time.now, registrant: contact, name: 'ghi.ph'
      create :domain, registered_at: Time.now, registrant: contact, name: 'jkl.ph'
    end

    specify { subject.count.must_equal 4 }
    specify { subject[0].full_name.must_equal 'jkl.ph' }
    specify { subject[1].full_name.must_equal 'ghi.ph' }
    specify { subject[2].full_name.must_equal 'def.ph' }
    specify { subject[3].full_name.must_equal 'abc.ph' }
  end

  describe :transfer! do
    subject { create :domain, partner: old_partner }

    let(:old_partner) { create :partner }
    let(:partner) { create :partner }
    let(:latest_activity) { subject.domain_activities.last }

    before do
      subject.transfer! to: partner
    end

    specify { subject.partner.must_equal partner }
    specify { latest_activity.must_be_kind_of ObjectActivity::Transfer }
    specify { latest_activity.losing_partner.must_equal old_partner }
  end

  describe :destroy do
    subject { DeletedDomain.find_by(name: domain.full_name) }

    let(:domain) { create :complete_domain }
    let(:activities) { subject.product.object_activities }

    before do
      create :domain_host, product: domain.product

      domain.destroy
    end

    specify { subject.product.must_equal domain.product }
    specify { subject.partner.must_equal domain.partner }
    specify { subject.name.must_equal domain.full_name }
    specify { subject.authcode.must_equal domain.authcode }
    specify { subject.registrant_handle.must_equal domain.registrant_handle }
    specify { subject.admin_handle.must_equal domain.admin_handle }
    specify { subject.billing_handle.must_equal domain.billing_handle }
    specify { subject.tech_handle.must_equal domain.tech_handle }
    specify { subject.registered_at.must_equal domain.registered_at }
    specify { subject.expires_at.must_equal domain.expires_at }
    specify { subject.deleted_at.wont_be_nil }
    specify { subject.domain_id.must_equal domain.id }

    specify { subject.product.domain_hosts.must_be_empty }

    specify { activities[7].must_be_kind_of ObjectActivity::Update }
    specify { activities[7].property_changed.must_equal 'domain_host' }
    specify { activities[7].old_value.must_equal 'ns5.domains.ph' }
    specify { activities[7].value.must_be_nil }
  end

  describe :delete_domain! do
    subject { create :domain }

    before do
      subject.delete_domain! on: deleted_at
    end

    let(:deleted_domain) { DeletedDomain.find_by(name: subject.name) }
    let(:deleted_at) { '2015-06-05 6:00 PM'.in_time_zone }

    specify { Domain.named(subject.name).must_be_nil }
    specify { deleted_domain.wont_be_nil }
    specify { deleted_domain.deleted_at.must_equal deleted_at }
  end
end
