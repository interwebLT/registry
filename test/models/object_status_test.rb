require 'test_helper'

describe ObjectStatus do
  describe :associations do
    subject { create :domain }

    specify { subject.product.wont_be_nil }
  end

  describe :enforce_status do
    subject { create :domain }

    let(:domain) { subject }
    let(:activities) { domain.domain_activities }

    context :when_created do
      specify { subject.ok.must_equal false }
      specify { subject.inactive.must_equal true }
      specify { subject.client_hold.must_equal false }
      specify { subject.client_delete_prohibited.must_equal false }
      specify { subject.client_renew_prohibited.must_equal false }
      specify { subject.client_transfer_prohibited.must_equal false }
      specify { subject.client_update_prohibited.must_equal false }
    end

    context :when_domain_hosts_exists do
      before do


        create :domain_host, product: subject.product, name: 'ns3.domains.ph'
        create :domain_host, product: subject.product, name: 'ns4.domains.ph'
      end

      specify { subject.ok.must_equal true }
      specify { subject.inactive.must_equal false }
      specify { subject.client_hold.must_equal false }
      specify { subject.client_delete_prohibited.must_equal false }
      specify { subject.client_renew_prohibited.must_equal false }
      specify { subject.client_transfer_prohibited.must_equal false }
      specify { subject.client_update_prohibited.must_equal false }

      specify { activities.count.must_equal 5 }

      specify { activities[2].must_be_kind_of ObjectActivity::Update }
      specify { activities[2].property_changed.must_equal 'ok' }
      specify { activities[2].old_value.must_equal 'false' }
      specify { activities[2].value.must_equal 'true' }

      specify { activities[3].must_be_kind_of ObjectActivity::Update }
      specify { activities[3].property_changed.must_equal 'inactive' }
      specify { activities[3].old_value.must_equal 'true' }
      specify { activities[3].value.must_equal 'false' }
    end

    context :when_client_hold do
      before do
        subject.update(client_hold: true)
      end

      specify { subject.client_hold.must_equal true }
    end

    context :when_client_delete_prohibited do
      before do
        subject.update(client_delete_prohibited: true)
      end

      specify { subject.client_delete_prohibited.must_equal true }
    end

    context :when_client_renew_prohibited do
      before do
        subject.update(client_renew_prohibited: true)
      end

      specify { subject.client_renew_prohibited.must_equal true }
    end

    context :when_client_transfer_prohibited do
      before do
        subject.update(client_transfer_prohibited: true)
      end

      specify { subject.client_transfer_prohibited.must_equal true }
    end

    context :when_client_update_prohibited do
      before do
        subject.update(client_update_prohibited: true)
      end

      specify { subject.client_update_prohibited.must_equal true }
    end

    context :when_client_hold_unset do
      before do
        subject.update(client_hold: true)
        subject.update(client_hold: false)
      end

      specify { subject.client_hold.must_equal false }
    end

    context :when_client_delete_prohibited_unset do
      before do
        subject.update(client_delete_prohibited: true)
        subject.update(client_delete_prohibited: false)
      end

      specify { subject.client_delete_prohibited.must_equal false }
    end

    context :when_client_renew_prohibited_unset do
      before do
        subject.update(client_renew_prohibited: true)
        subject.update(client_renew_prohibited: false)
      end

      specify { subject.client_renew_prohibited.must_equal false }
    end

    context :when_client_transfer_prohibited_unset do
      before do
        subject.update(client_transfer_prohibited: true)
        subject.update(client_transfer_prohibited: false)
      end

      specify { subject.client_transfer_prohibited.must_equal false }
    end

    context :when_client_update_prohibited_unset do
      before do
        subject.update(client_update_prohibited: true)
        subject.update(client_update_prohibited: false)
      end

      specify { subject.client_update_prohibited.must_equal false }
    end
  end
end
