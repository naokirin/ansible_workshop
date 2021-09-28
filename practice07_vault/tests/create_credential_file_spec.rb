# http://inspec.io/docs/reference/resources/file/
describe file('/tmp/credential') do
  it { should exist }
  its('content') { should match /CREDENTIAL_FILE/ }
end

# http://inspec.io/docs/reference/resources/file/
describe file('/tmp/name_and_password') do
  it { should exist }
  its('content') { should match /name=foo/ }
  its('content') { should match /password=secret_string/ }
end
