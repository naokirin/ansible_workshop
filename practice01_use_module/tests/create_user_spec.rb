# http://inspec.io/docs/reference/resources/user/
describe user('test_user') do
  it { should exist }
  its('shell') { should eq '/bin/bash' }
end