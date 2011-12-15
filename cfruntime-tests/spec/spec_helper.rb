require 'vmc'
require 'cli'
require 'curb'
module CFRuntimeTests

  def deploy_app app_name,app_dir,runtime='ruby18',start=false
    create_app app_name
    upload_app app_name,app_dir
    if start
      start_app app_name
    end
  end

  def login
    @client = VMC::Client.new(@target_url)
    @client.login(@test_user,@test_pwd)
  end

  def create_uri name
    "#{name}.#{@target}"
  end

  def create_app app, framework='sinatra', runtime='ruby18', instances=1, memory=64
    delete_app app
    url = create_uri app
    manifest = {
      :name => "#{app}",
      :staging => {
      :framework => framework,
      :runtime => runtime
      },
      :resources=> {
        :memory => memory
      },
      :uris => [url],
      :instances => "#{instances}",
    }
    response = @client.create_app(app, manifest)
    if response.first == 400
      puts "Creation of app #{app} failed"
      return
    end
  end

  def delete_app app
    begin
      response = @client.delete_app(app)
    rescue
    end
    response
  end

  def upload_app app,app_dir
    upload_file, file = "#{Dir.tmpdir}/#{app}.zip", nil
    FileUtils.rm_f(upload_file)
    explode_dir = "#{Dir.tmpdir}/.vmc_#{app}_files"
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
      @client.upload_app(app, file)
    end
    ensure
      # Cleanup if we created an exploded directory.
      FileUtils.rm_f(upload_file) if upload_file
      FileUtils.rm_rf(explode_dir) if explode_dir
  end

  def start_app app
    app_manifest = get_app_status app
    if app_manifest == nil
      raise "Application #{app} does not exist, app needs to be created."
    end
    if (app_manifest[:state] == 'STARTED')
      return
    end
    app_manifest[:state] = 'STARTED'
    response = @client.update_app(app, app_manifest)
    raise "Problem starting application #{app}." if response.first != 200
    expected_health = 1.0
    health = poll_until_done app, expected_health
    health.should == expected_health
  end

  def stop_app app
    app_manifest = get_app_status app
    if app_manifest == nil
      raise "Application #{app} does not exist."
    end
    if (app_manifest[:state] == 'STOPPED')
      return
    end
    app_manifest[:state] = 'STOPPED'
    @client.update_app(app, app_manifest)
  end

  def poll_until_done app, expected_health
    secs_til_timeout = 60
    health = nil
    sleep_time = 1
    while secs_til_timeout > 0 && health != expected_health
      sleep sleep_time
      secs_til_timeout = secs_til_timeout - sleep_time
      status = get_app_status app
      runningInstances = status[:runningInstances] || 0
      health = runningInstances/status[:instances].to_f
    end
    health
  end

  def get_app_status app
    begin
      response = @client.app_info(app)
    rescue
      nil
    end
  end

  def provision_db_service name,app
    @client.create_service(:mysql, name)
    service_manifest = {
      :type=>"database",
      :vendor=>"mysql",
      :tier=>"free",
      :version=>"5.1.45",
      :name=>name,
      :options=>{"size"=>"256MiB"},
    }
    attach_provisioned_service app,service_manifest
  end

  def provision_redis_service name,app
    @client.create_service(:redis, name)
    service_manifest = {
      :type=>"key-value",
      :vendor=>"redis",
      :tier=>"free",
      :version=>"5.1.45",
      :name=>name,
    }
    attach_provisioned_service app,service_manifest
  end

  def provision_mongodb_service name,app
    @client.create_service(:mongodb, name)
    service_manifest = {
      :type=>"key-value",
      :vendor=>"mongodb",
      :tier=>"free",
      :version=>"1.8",
      :name=>name,
      :options=>{"size"=>"256MiB"}}
    attach_provisioned_service app,service_manifest
  end

  def provision_rabbitmq_service name,app
    @client.create_service(:rabbitmq, name)
    service_manifest = {
      :type=>"generic",
      :vendor=>"rabbitmq",
      :tier=>"free",
      :version=>"2.4",
      :name=>name,
      :options=>{"size"=>"256MiB"}}
    attach_provisioned_service app,service_manifest
  end

  def provision_postgresql_service name,app
    @client.create_service(:postgresql, name)
    service_manifest = {
      :type=>"database",
      :vendor=>"postgresql",
      :tier=>"free",
      :version=>"9.0",
      :name=>name,
      :options=>{"size"=>"256MiB"},
    }
    attach_provisioned_service app,service_manifest
  end

  def attach_provisioned_service app, service_manifest
    app_manifest = get_app_status app
    provisioned_service = app_manifest[:services]
    provisioned_service = [] unless provisioned_service
    svc_name = service_manifest[:name]
    provisioned_service << svc_name
    app_manifest[:services] = provisioned_service
    @client.update_app(app, app_manifest)
  end

  def all_my_services
    @client.services.map{ |service| service[:name] }
  end

  def delete_services services
    services.each do |service|
      delete_service service
    end
  end

  def delete_service service
    begin
      @client.delete_service(service)
    rescue
      nil
    end
  end

  def verify_post_to_app app,relative_path,data
    contents = post_to_app app,relative_path,data
    contents.response_code.should == 200
    contents.close
    contents = get_app_contents app,relative_path
    contents.should_not == nil
    contents.body_str.should_not == nil
    contents.response_code.should == 200
    contents.body_str.should == data
    contents.close
  end

  def post_to_app app, relative_path, data
    uri = get_uri app, relative_path
    post_uri uri, data
  end

  def post_uri uri, data
    easy = Curl::Easy.new
    easy.url = uri
    easy.http_post(data)
    easy
  end

  def get_uri app, relative_path=nil
    uri = "#{app}.#{@target}"
    if relative_path != nil
      uri << "/#{relative_path}"
    end
    uri
  end

  def get_app_contents app, relative_path=nil
    uri = get_uri app, relative_path
    get_uri_contents uri
  end

  def get_uri_contents uri, timeout=0
    easy = Curl::Easy.new
    easy.url = uri
    if timeout != 0
      easy.timeout = timeout
    end
    easy.http_get
    easy
  end
end