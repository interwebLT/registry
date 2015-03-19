def get_domains 
  get domains_url
end

def assert_domains_only_belong_to_current_user
  assert json_response.length == 1
end