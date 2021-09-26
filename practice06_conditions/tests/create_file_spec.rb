# http://inspec.io/docs/reference/resources/file/
describe file('/tmp/test_file') do
  it { should exist }
end