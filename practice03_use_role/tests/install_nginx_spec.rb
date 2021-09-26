# http://inspec.io/docs/reference/resources/user/
describe user('nginx') do
  it { should exist }
end

# http://inspec.io/docs/reference/resources/package/
describe package('nginx') do
  it { should be_installed }
end

# http://inspec.io/docs/reference/resources/service/
describe service('nginx') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# http://inspec.io/docs/reference/resources/file/
describe file('/etc/nginx/nginx.conf') do
  it { should exist }
  its('content') { should match /# サンプル用のnginx.conf/ }
end