# http://inspec.io/docs/reference/resources/user/
describe user('test_user') do
  it { should exist }
  its('shell') { should eq '/bin/bash' }
end

# http://inspec.io/docs/reference/resources/directory/
describe directory('/home/test_user/test_dir') do
  it { should exist }
  its('mode') { should cmp '0755' }
end

# http://inspec.io/docs/reference/resources/file/
describe file('/home/test_user/.bashrc') do
  it { should exist }
  its('content') { should match /export HOST_ENV_NAME=dev/ }
end