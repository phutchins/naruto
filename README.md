# Naruto
Chef LWRP for parsing templates recursively in a directory and automatically populating your variables hash from a hash attribute

## Depends
You must add naruto to your metadata.rb

## Attributes
Populate an attribute with a hash to use as your variable keys (names) and values

You can add common values to get parsed into all templates

    node.set['mycookbook']['myapp']['db_host'] = 'host1'
    node.set['mycookbook']['myapp']['db_user'] = 'user1'
    node.set['mycookbook']['myapp']['db_pass'] = 'greatpassword'
    node.set['mycookbook']['myapp']['db_name'] = 'awesomedb'

Add app or template specific values to only be parsed into certain templates

    node.set['mycookbook']['common']['log_dir'] = '/var/log'
    node.set['mycookbook']['common']['tmp_dir'] = '/tmp'    

#### Create merged hash of attributes that we need to parse into the templates
    myapp_variables = {}
    myapp_variables = node['mycookbook']['common'].to_hash.merge(node['mycookbook']['myapp'].to_hash)

## Resource Usage
    naruto_recursive_parse 'myapp_templates' do
      action :create
      base_dir "/opt/myapp"
      variables myapp_variables
      notifies :restart, 'service[myapp]'
    end
