require 'vmc'
require 'cli'
require 'curb'
module CFRuntimeTests

  SERVICE_NAMES = {
    :redis => "redis",
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
    @client = VMC::Client.new(target_url)
    @client.login(test_user, test_pwd)
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

  def domain
    target.split(".")[1..-1].join(".")
  end

  def app_name
    "cfruntime-svc-test"
  end

  def app_uri
    "#{app_name}.#{domain}"
  end

  def system_services
    login unless @client
    @system_services ||= @client.services_info
  end

  def service_available?(name)
    system_services.each do |_, services|
      services.each do |service_name, _|
        return true if service_name == name
      end
    end
    false
  end

  def create_app(framework='sinatra', runtime='ruby18', instances=1, memory=64)
    delete_app
    manifest = {
      :name => "#{app_name}",
      :staging => {
      :framework => framework,
      :runtime => runtime
      },
      :resources=> {
        :memory => memory
      },
      :uris => [app_uri],
      :instances => "#{instances}",
    }
    response = @client.create_app(app_name, manifest)
    if response.first == 400
      puts "Creation of app #{app_name} failed"
    end
  end

  def delete_app
    @client.delete_app(app_name)
  rescue
    nil
  end

  def upload_app(app_dir)
    upload_file, file = "#{Dir.tmpdir}/#{app_name}.zip", nil
    FileUtils.rm_f(upload_file)
    explode_dir = "#{Dir.tmpdir}/.vmc_#{app_name}_files"
    FileUtils.rm_rf(explode_dir) # Make sure we didn't have anything left over..
    Dir.chdir(app_dir) do
      FileUtils.mkdir(explode_dir)
      files = Dir.glob('{*,.[^\.]*}')
      # Do not process .git files
      files.delete('.git') if files
      FileUtils.cp_r(files, explode_dir)
      unless VMC::Cli::ZipUtil.get_files_to_pack(explode_dir).empty?
        VMC::Cli::ZipUtil.pack(explode_dir, upload_file)
        file = File.open(upload_file, 'rb')
      end
      @client.upload_app(app_name, file)
    end
  ensure
    # Cleanup if we created an exploded directory.
    FileUtils.rm_f(upload_file) if upload_file
    FileUtils.rm_rf(explode_dir) if explode_dir
  end

  def start_app
    app_manifest = get_app_status
    if app_manifest == nil
      raise "Application #{app_name} does not exist, app needs to be created."
    end
    if app_manifest[:state] == 'STARTED'
      return
    end
    app_manifest[:state] = 'STARTED'
    response = @client.update_app(app_name, app_manifest)
    raise "Problem starting application #{app_name}." if response.first != 200
    expected_health = 1.0
    health = poll_until_done(expected_health)
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

  def poll_until_done(expected_health)
    secs_til_timeout = 60
    health = nil
    sleep_time = 1
    while secs_til_timeout > 0 && health != expected_health
      sleep sleep_time
      secs_til_timeout = secs_til_timeout - sleep_time
      status = get_app_status
      runningInstances = status[:runningInstances] || 0
      health = runningInstances/status[:instances].to_f
    end
    health
  end

  def get_app_status
    @client.app_info(app_name)
  rescue
    nil
  end

  def provision_service(app_name, service_name)
    label = "test-#{app_name}-#{SERVICE_NAMES[service_name]}"
    @client.create_service(service_name, label)
    service_manifest = service_manifest(service_name, label)
    attach_provisioned_service(service_manifest)
    restart_app
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
      :mongodb => mongo_service_manifest,
      :mysql => mysql_service_manifest,
      :postgresql => postgresql_service_manifest,
      :rabbitmq => rabbit_service_manifest,
      :blob => blob_service_manifest
    }

    manifests[service_name].merge(:name => name)
  end

  def attach_provisioned_service(service_manifest)
    app_manifest = get_app_status
    provisioned_services = app_manifest[:services] || []

    provisioned_services << service_manifest[:name]
    app_manifest[:services] = provisioned_services
    @client.update_app(app_name, app_manifest)
  end

  def all_my_services
    @client.services.map{ |service| service[:name] }
  end

  def delete_services(services)
    services.each do |service|
      delete_service service
    end
  end

  def delete_service(service)
    @client.delete_service(service)
  rescue
    nil
  end

  def verify_service(service_name)
    pending "Service #{service_name} is not available on #{target}" unless service_available?(service_name)

    provision_service(app_name, service_name)

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