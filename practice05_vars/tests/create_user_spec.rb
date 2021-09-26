# http://inspec.io/docs/reference/resources/user/
describe user('test_user') do
  it { should exist }
end

# http://inspec.io/docs/reference/resources/user/
describe user('foo_user') do
  it { should exist }
end