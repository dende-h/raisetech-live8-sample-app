require 'spec_helper'

listen_port = 80

# OSの判定とawscliの有無
if os[:family] == 'amazon'
  describe package('aws-cli') do
    it { should be_installed }
  end
end

# パッケージのインストール確認
%w{
  git make gcc-c++ patch openssl-devel libyaml-devel libffi-devel libicu-devel
  libxml2 libxslt libxml2-devel libxslt-devel zlib-devel readline-devel
  ImageMagick ImageMagick-devel epel-release nginx mysql-devel mysql
}.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

# unicornの確認
describe gem('unicorn') do
  it { should be_installed }
end

# Nginxの起動状態
describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

#Unicornの起動状態
describe process("unicorn") do
  it { should be_running }
end

# rubyのバージョン確認
describe command('ruby -v') do
  its(:stdout) { should match /ruby 3\.1\.2/ }
end

# bundlerのバージョン確認
describe command('bundle -v') do
  its(:stdout) { should match /Bundler version 2\.3\.14/ } 
end

# Railsのバージョン確認
describe command('rails -v') do
  its(:stdout) { should match /Rails 7\.0\.4/ } # ここに期待するバージョンを記述
end

# Nodeのバージョン確認
describe command('node -v') do
  its(:stdout) { should match /v17\.9\.1/ } # ここに期待するバージョンを記述
end

# yarnのバージョン確認
describe command('yarn -v') do
  its(:stdout) { should match /1\.22\.19/ } # ここに期待するバージョンを記述
end

# hostが到達可能であるか
describe host('Lecture10-alb-1385515351.ap-northeast-1.elb.amazonaws.com') do
  it { should be_reachable }
end

# ポートが開かれているか
describe port(listen_port) do
  it { should be_listening }
end

# 指定されたURLに対してHTTPリクエストを送信し、レスポンスのHTTPステータスコードが200（成功）であることを確認するテスト。レスポンスボディの内容は確認せず、HTTPコードを対象とする。
describe command("curl http://13.231.108.50:#{listen_port}/ -o /dev/null -w '%{http_code}\n' -s") do
  its(:stdout) { should match /^200$/ }
end

describe http('http://13.231.108.50') do
  its(:status) { should eq 200 }
end

# RDSの接続確認
describe command("mysql -h lecture10-db.ckqxv4ruunm2.ap-northeast-1.rds.amazonaws.com -u #{ENV['DATA_BASE_USERNAME']} -p#{ENV['DATABASE_PASSWORD']} -e 'show databases;'") do
  its(:exit_status) { should eq 0 }
end

# S3接続確認
describe command("aws s3 ls s3://lecture10s3bk") do
  its(:exit_status) { should eq 0 }
end

#ALB接続状態確認
describe command("aws elbv2 describe-target-health --target-group-arn #{ENV['TARGET_GROUP_ARN']}") do
  its(:stdout) { should match /"State":"healthy"/ }
end