require File.join(File.dirname(__FILE__), 'spec_helper')
describe 'CFRuntime' do
  include CFRuntimeTests

  before(:each) do
    @app_name='cfruntime-svc-test'
    @test_user = ENV['VCAP_EMAIL'] || "vcap-ruby-test-user@vmware.com"
    @test_pwd = ENV['VCAP_PWD'] || "tester123"
    @target = ENV['VCAP_TARGET'] || "cloudfoundry.com"
    @target_url = "http://api.#{@target}"
    puts "Running tests on #{@target_url} on behalf of #{@test_user}"
    login
  end

  after(:each) do
    delete_services all_my_services
  end

  it 'connects an application to services by type' do
    deploy_and_provision_svcs @app_name,File.join(File.dirname(__FILE__),'assets/service_bindings_by_type')
    verify_post_to_app @app_name, "service/mysql/abc", 'mysqlabc'
    verify_post_to_app @app_name, "service/redis/abc", 'redisabc'
    verify_post_to_app @app_name, "service/mongo/abc", 'mongoabc'
    verify_post_to_app @app_name, "service/rabbit/abc", 'rabbitabc'
    verify_post_to_app @app_name, "service/postgresql/abc", 'postgresqlabc'
    contents = post_to_app @app_name, "service/blob/container1", "dummy"
    contents.response_code.should == 200
    contents.close
    verify_post_to_app @app_name, "service/blob/container1/file1", "abc"
    delete_app @app_name
  end

  it 'connects an application to services by name' do
    deploy_and_provision_svcs @app_name,File.join(File.dirname(__FILE__),'assets/service_bindings_by_name')
    stop_app @app_name
    start_app @app_name
    provision_db_service("test-#{@app_name}2-mysql",@app_name)
    provision_redis_service("test-#{@app_name}2-redis",@app_name)
    provision_rabbitmq_service("test-#{@app_name}2-rabbit",@app_name)
    provision_mongodb_service("test-#{@app_name}2-mongo",@app_name)
    provision_postgresql_service("test-#{@app_name}2-postgres",@app_name)
    start_app @app_name
    verify_post_to_app @app_name, "service/mysql/abc", "mysqlabc"
    verify_post_to_app @app_name, "service/redis/abc", "redisabc"
    verify_post_to_app @app_name, "service/mongo/abc", "mongoabc"
    verify_post_to_app @app_name, "service/rabbit/abc", "rabbitabc"
    verify_post_to_app @app_name, "service/postgresql/abc", "postgresqlabc"
    contents = post_to_app @app_name, "service/blob/container1", "dummy"
    contents.response_code.should == 200
    contents.close
    verify_post_to_app @app_name, "service/blob/container1/file1", "abc"
    delete_app @app_name
  end

  #The AMQP gem doesn't play well on ruby1.8, and some other svcs don't do well on 1.9
  #So we test separately
  it 'connects an application using AMQP to rabbit service by type' do
    deploy_app @app_name,File.join(File.dirname(__FILE__),'assets/amqp_service_bindings_by_type'),'ruby19'
    provision_rabbitmq_service("test-#{@app_name}-rabbit",@app_name)
    start_app @app_name
    verify_post_to_app @app_name, "service/amqp/abc", 'rabbitabc'
    delete_app @app_name
  end

  #The AMQP gem doesn't play well on ruby1.8, and some other svcs don't do well on 1.9
  #So we test separately
  it 'connects an application using AMQP to rabbit service by name' do
    deploy_app @app_name,File.join(File.dirname(__FILE__),'assets/amqp_service_bindings_by_name'),'ruby19'
    provision_rabbitmq_service("test-#{@app_name}-rabbit",@app_name)
    start_app @app_name
    verify_post_to_app @app_name, "service/amqp/abc", 'rabbitabc'
    delete_app @app_name
  end

  def deploy_and_provision_svcs app,app_dir
    deploy_app app,app_dir
    provision_db_service("test-#{app}-mysql",app)
    provision_redis_service("test-#{app}-redis",app)
    provision_rabbitmq_service("test-#{app}-rabbit",app)
    provision_mongodb_service("test-#{app}-mongo",app)
    provision_postgresql_service("test-#{app}-postgres",app)
    provision_blob_service("test-#{app}-blob",app)
    start_app app
  end
end