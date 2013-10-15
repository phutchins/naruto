# Naruto
## Chef LWRP for parsing templates recursively in a directory and automatically populating your variables hash from a hash attribute

## Create merged hash of attributes that we need to parse into the templates
  social_variables = {}
  social_variables = node['myattr']['common'].to_hash.merge(node['myattr']['drooler'].to_hash)

## Resource Usage
  naruto_recursive_parse 'drooler_templates' do
    action :create
    base_dir "/opt/social"
    variables social_variables
    notifies :restart, 'service[drooler]'
  end
