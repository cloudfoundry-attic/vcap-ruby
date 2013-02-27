#cf-runtime

A library for interacting with Cloud Foundry services.  Provides methods for obtaining pre-configured connection objects and connection properties.

_Copyright (c) 2011-2012 VMware, Inc. Please see the LICENSE file._

require 'cf-runtime'

#Connect to mysql service named 'mysql-test'
client = CFRuntime::Mysql2Client.create_from_svc 'mysql-test'

#Connect to a single service of type MongoDB
connection = CFRuntime::MongoClient.create
db = connection.db

#Obtain connection properties for 'myservice'
if CFRuntime::CloudApp.running_in_cloud?
  service_props = CFRuntime::CloudApp.service_props 'myservice'
end

#Obtain connection properties for single service of type MySQL
service_props = CFRuntime::CloudApp.service_props 'mysql'

#Other handy methods
CFRuntime::CloudApp.host
CFRuntime::CloudApp.port
CFRuntime::CloudApp.service_names
CFRuntime::CloudApp.service_names_of_type 'mysql'
