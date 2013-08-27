require 'cfoundry'
require 'curb'
module CFRuntimeTests

  SERVICE_NAMES = {
    :redis => "redis",
    :memcached => "memcached",
    :mongodb => "mongo",
    :mysql => "mysql",
    :postgresql => "postgresql",
    :rabbitmq => "rabbit",
    :blob => "blob"
  }

  def deploy_app(app_dir, start=false)
    app_path = File.join(File.dirname(__FILE__), "assets", app_dir)
    create_app
    upload_app(app_path)
    start_app if start
  end

  def login
    target_url = "http://#{target}"
    puts "Running tests on #{target_url} on behalf of #{test_user}"
    @client = CFoundry::Client.get(target_url)
    @client.login(username: test_user, password: test_pwd)
    select_org_and_space if v2?
  end

  def test_user
    ENV['VCAP_EMAIL'] || "vcap-ruby-test-user@vmware.com"
  end

  def test_pwd
    ENV['VCAP_PWD'] || "tester123"
  end

  def target
    ENV['VCAP_TARGET'] || "api.cloudfoundry.com"
  end

  def organization
    ENV['VCAP_ORG'] || raise("Provide organization name in VCAP_ORG")
  end

  def space
    ENV['VCAP_SPACE'] || raise("Provide space name in VCAP_SPACE")
  end

  def domain_name
    target.split(".")[1..-1].join(".")
  end

  def app_name
    "cfruntime-svc-test"
  end

  def app_uri
    "#{app_name}.#{domain_name}"
  end

  def v2?
    @client.is_a?(CFoundry::V2::Client)
  end

  def select_org_and_space
    @client.current_organization = @client.organization_by_name(organization)
    @client.current_space = @client.current_organization.space_by_name(space)
  end

  def system_services
    login unless @client
    @system_services ||= @client.services
  end

  def service_available?(name)
    !!system_service(name)
  end

  def system_service(name)
    system_services.find { |s| s.label == name.to_s && s.provider == "core" }
  end

  def create_app(framework='sinatra', runtime='ruby18', instances=1, memory=256)
    delete_app
    @app = @client.app
    @app.name = app_name
    @app.space = @client.current_space if v2?
    @app.total_instances = instances
    @app.command = "bundle exec ruby app.rb -p $PORT"
    @app.memory = memory

    unless v2?
      @app.framework = @client.framework_by_name(framework)
      @app.runtime = @client.runtime_by_name(runtime)
    end

    @app.create!
    map_url
  end

  def map_url
    if v2?
      domain = @client.current_space.domain_by_name(domain_name)
      route = @client.routes_by_host(app_name, :depth => 0).find do |r|
        r.domain == domain
      end
      unless route
        route = @client.route
        route.host = app_name
        route.domain = domain
        route.space = @client.current_space
        route.create!
      end
      @app.add_route(route)
    else
      @app.urls << app_uri
      @app.update!
    end
  end

  def delete_app
    return unless @client
    return unless @client.app_by_name(app_name)
    app = @client.app_by_name(app_name)
    if v2?
      app.routes.each do |route|
        route.delete!
      end
    end
    app.delete!
  end

  def upload_app(app_path)
    @app.upload(app_path)
  end

  def start_app
    puts "Starting application (please wait)"
    @app.start!
    expected_health = "RUNNING"
    health = poll_until_done
    health.should == expected_health
  end

  def stop_app
    app_manifest = get_app_status
    if app_manifest == nil
      raise "Application #{app_name} does not exist."
    end
    if (app_manifest[:state] == 'STOPPED')
      return
    end
    app_manifest[:state] = 'STOPPED'
    @client.update_app(app_name, app_manifest)
  end

  def restart_app
    stop_app
    start_app
  end

  def poll_until_done
    secs_til_timeout = 60
    sleep_time = 1
    while secs_til_timeout > 0 && !@app.healthy?
      sleep sleep_time
      secs_til_timeout = secs_til_timeout - sleep_time
    end
    @app.health
  end

  def get_app_status
    @app && @app.state
  end

  def provision_service(service_type, prefix)
    return unless service_available?(service_type)
    service_instance = @client.service_instance
    service_instance.name = "#{prefix}-#{app_name}-#{SERVICE_NAMES[service_type]}"
    system_service = system_service(service_type)
    if v2?
      service_instance.space = @client.current_space
      service_instance.service_plan = system_service.service_plans.first
    else
      service_instance.vendor = system_service.label
      service_instance.tier = "free"
      service_instance.version = system_service.version
    end
    service_instance.create!
    attach_provisioned_service(service_instance)
    sleep 1 # Wait for service to start
  end

  def mysql_service_manifest
    {
      :type=>"database",
      :vendor=>"mysql",
      :tier=>"free",
      :version=>"5.1.45",
      :options=>{"size"=>"256MiB"},
    }
  end

  def redis_service_manifest
    {
      :type=>"key-value",
      :vendor=>"redis",
      :tier=>"free",
      :version=>"5.1.45",
    }
  end

  def memcached_service_manifest
    {
      :type=>"key-value",
      :vendor=>"memcached",
      :tier=>"free",
      :version=>"1.4",
    }
  end

  def mongo_service_manifest
    {
      :type=>"key-value",
      :vendor=>"mongodb",
      :tier=>"free",
      :version=>"1.8",
      :options=>{"size"=>"256MiB"}
    }
  end

  def rabbit_service_manifest
    {
      :type=>"generic",
      :vendor=>"rabbitmq",
      :tier=>"free",
      :version=>"2.4",
      :options=>{"size"=>"256MiB"}
    }
  end

  def postgresql_service_manifest
    {
      :type=>"database",
      :vendor=>"postgresql",
      :tier=>"free",
      :version=>"9.0",
      :options=>{"size"=>"256MiB"},
    }
  end

  def blob_service_manifest
    {
      :type=>"generic",
      :vendor=>"blob",
      :tier=>"free",
      :version=>"0.5.1",
    }
  end

  def service_manifest(service_name, name)
    manifests = {
      :redis => redis_service_manifest,
      :memcached => memcached_service_manifest,
      :mongodb => mongo_service_manifest,
      :mysql => mysql_service_manifest,
      :postgresql => postgresql_service_manifest,
      :rabbitmq => rabbit_service_manifest,
      :blob => blob_service_manifest
    }

    manifests[service_name].merge(:name => name)
  end

  def attach_provisioned_service(service_instance)
    @app.bind(service_instance)
  end

  def delete_services
    services = v2? ? @client.current_space.service_instances : @client.service_instances
    services.each do |service|
      service.delete!
    end
  rescue CFoundry::NotFound
    # Service was already removed
  end

  def verify_service(service_name)
    pending "Service #{service_name} is not available on #{target}" unless service_available?(service_name)

    service_key = SERVICE_NAMES[service_name]
    if service_name == :blob
      contents = post_to_app("service/#{service_key}/container1", "dummy")
      contents.response_code.should == 200
      contents.close
      verify_post_to_app("service/#{service_key}/container1/file1", "abc")
    else
      verify_post_to_app("service/#{service_key}/abc", "#{service_key}abc")
    end
  end

  def verify_post_to_app(relative_path, data)
    contents = post_to_app(relative_path, data)
    p(body: contents.body_str) if contents.response_code != 200
    contents.response_code.should == 200
    contents.close
    contents = get_app_contents(relative_path)
    contents.should_not == nil
    contents.body_str.should_not == nil
    contents.response_code.should == 200
    contents.body_str.should == data
    contents.close
  end

  def post_to_app(relative_path, data)
    uri = get_uri(relative_path)
    post_uri uri, data
  end

  def post_uri uri, data
    easy = Curl::Easy.new
    easy.url = uri
    easy.http_post(data)
    easy
  end

  def get_uri(relative_path=nil)
    if relative_path
      "#{app_uri}/#{relative_path}"
    else
      app_uri
    end
  end

  def get_app_contents(relative_path=nil)
    uri = get_uri(relative_path)
    get_uri_contents uri
  end

  def get_uri_contents(uri, timeout=0)
    easy = Curl::Easy.new
    easy.url = uri
    if timeout != 0
      easy.timeout = timeout
    end
    easy.http_get
    easy
  end
end
