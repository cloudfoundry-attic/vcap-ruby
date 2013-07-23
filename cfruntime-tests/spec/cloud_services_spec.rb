require File.join(File.dirname(__FILE__), "spec_helper")

describe "CFRuntime" do
  include CFRuntimeTests

  TEST_SERVICES = [:mysql, :redis, :mongodb, :rabbitmq, :postgresql, :blob, :memcached]

  describe "connects an application to services by type" do
    before(:all) do
      login
      delete_app
      delete_services
      deploy_app("service_bindings_by_type")
      TEST_SERVICES.each { |service_name| provision_service(service_name, "test-type") }
      start_app
    end

    after(:all) do
      delete_app
      delete_services
    end

    TEST_SERVICES.each do |service_name|
      it "connects to #{service_name} by type" do
        verify_service(service_name)
      end
    end
  end

  describe "connects an application to services by name" do
    before(:all) do
      login
      delete_services
      deploy_app("service_bindings_by_name")
      TEST_SERVICES.each { |service_name| provision_service(service_name, "test-name") }
      start_app
    end

    after(:all) do
      delete_app
      delete_services
    end

    TEST_SERVICES.each do |service_name|
      it "connects to #{service_name} by name" do
        verify_service(service_name)
      end
    end
  end

  # The AMQP gem doesn't play well on ruby1.8, and some other svcs don't do well on 1.9
  # So we test separately
  describe "connects an application using AMQP to rabbit service by type" do
    before do
      login
      delete_services
      deploy_app("amqp_service_bindings_by_type")
      provision_service(:rabbitmq, "amqp-type")
      start_app
    end

    after do
      delete_app
      delete_services
    end

    it "connects to rabbitmq by type" do
      verify_service(:rabbitmq)
    end
  end

  # The AMQP gem doesn't play well on ruby1.8, and some other svcs don't do well on 1.9
  # So we test separately
  describe "connects an application using AMQP to rabbit service by name" do
    before do
      login
      delete_services
      deploy_app("amqp_service_bindings_by_name")
      provision_service(:rabbitmq, "amqp-name")
      start_app
    end

    after do
      delete_services
      delete_app
    end

    it "connects to rabbitmq by name" do
      verify_service(:rabbitmq)
      delete_services
    end
  end
end