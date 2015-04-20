def delete_domain
  saved_domain.destroy
end

def assert_domain_does_not_exist
  Domain.named(DOMAIN).must_be_nil
end

def assert_deleted_domain_exists
  DeletedDomain.exists?(name: DOMAIN).must_equal true
end

def assert_deleted_domain_must_not_have_domain_hosts
  DeletedDomain.find_by(name: DOMAIN).product.domain_hosts.must_be_empty
end
