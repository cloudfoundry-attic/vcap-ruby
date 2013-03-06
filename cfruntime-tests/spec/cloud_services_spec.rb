require File.join(File.dirname(__FILE__), "spec_helper")

describe "CFRuntime" do
  include CFRuntimeTests

  after(:each) do
    delete_services all_my_services
  end

  describe "connects an application to services by type" do
    before(:all) do
      login
      deploy_app("service_bindings_by_type")
    end

    after(:all) do
      delete_app
    end

    [:mysql, :redis, :mongodb, :rabbitmq, :postgresql, :blob].each do |service_name|
      it "connects to #{service_name} by type" do
        verify_service(service_name)
      end
    end
  end

  describe "connects an application to services by name" do
    before(:all) do
      login
      deploy_app("service_bindings_by_name")
    end

    after(:all) do
      delete_app
    end

    [:mysql, :redis, :mongodb, :rabbitmq, :postgresql, :blob].each do |service_name|
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
      deploy_app("amqp_service_bindings_by_type")
    end

    after do
      delete_app
    end

    it "connects to amqp by type" do
      verify_service(:rabbitmq)
    end
  end

  # The AMQP gem doesn't play well on ruby1.8, and some other svcs don't do well on 1.9
  # So we test separately
  describe "connects an application using AMQP to rabbit service by name" do
    before do
      login
      deploy_app("amqp_service_bindings_by_name")
    end

    after do
      delete_app
    end

    it "connects to amqp by name" do
      verify_service(:rabbitmq)
    end
  end
end