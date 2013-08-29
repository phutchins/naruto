actions :create
default_action :create
attribute :base_dir, :kind_of => String, :required => true
attribute :variables, :kind_of => Hash, :required => true
