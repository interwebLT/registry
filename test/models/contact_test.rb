require 'test_helper'

describe Contact do
  describe :associations do
    subject { create :contact }

    before do
      create :domain, name: 'abc', registrant: subject
      create :domain, name: 'def', registrant: subject

      create :contact_history, contact: subject, partner: subject.partner
      create :contact_history, contact: subject, partner: subject.partner
    end

    specify { subject.partner.wont_be_nil }
    specify { subject.contact_histories.wont_be_empty }
    specify { subject.contact_histories.wont_be_empty }
  end

  describe :valid do
    subject { build :contact }

    context :when_handle_missing do
      before do
        subject.handle = nil
      end

      specify { subject.valid?.must_equal false }
    end

    context :when_partner_missing do
      before do
        subject.partner = nil
      end

      specify { subject.valid?.must_equal false }
    end

    context :when_name_missing do
      before do
        subject.name = nil
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_organization_missing do
      before do
        subject.organization = nil
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_email_missing do
      before do
        subject.email = nil
      end

      specify { subject.valid?.must_equal true }
    end

    context :when_partner_admin do
      before do
        subject.partner = create :partner, admin: true

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:partner].must_equal ['invalid'] }
    end

    context :when_handle_exists do
      subject { build :contact }

      before do
        create :contact

        subject.valid?
      end

      specify { subject.valid?.must_equal false }
      specify { subject.errors.count.must_equal 1 }
      specify { subject.errors[:handle].must_equal ['already_exists'] }
    end
  end

  describe :callbacks do
    CONTACT_FIELDS = [
      :name, :organization, :street, :street2, :street3,
      :city, :state, :postal_code, :country_code,
      :local_name, :local_organization, :local_street, :local_street2, :local_street3,
      :local_city, :local_state, :local_postal_code, :local_country_code,
      :voice, :voice_ext, :fax, :fax_ext, :email
    ]

    subject { create :contact }

    context :when_create do
      specify { subject.contact_histories.count.must_equal 1 }
      specify { subject.contact_histories.first.contact.must_equal subject }
      specify { assert_latest_contact_history subject }
    end

    context :when_update do
      before do
        CONTACT_FIELDS.each do |field|
          subject.send "#{field.to_s}=", 'new'
        end

        subject.save
      end

      specify { subject.contact_histories.count.must_equal 2 }
      specify { assert_latest_contact_history subject }
    end
  end

  private

  def assert_latest_contact_history contact
    CONTACT_FIELDS.each do |field|
      contact.contact_histories.last.send(field).must_equal contact.send(field)
    end
  end
end
