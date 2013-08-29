require 'find'
require 'fileutils'

def forward_notifications(resource)
  if @immediate_notifications then
    @immediate_notifications.each do  |note|
      resource.notifies_immediately( note.action, note.resource )
    end
  end

  if @delayed_notifications then
    @delayed_notifications.each do  |note|
      resource.notifies_delayed( note.action, note.resource )
    end
  end
end

action :create do
  base_dir = new_resource.base_dir
  variables = new_resource.variables
  changed = false

  # Grab notifications to forward
  @immediate_notifications = new_resource.immediate_notifications
  @delayed_notifications   = new_resource.delayed_notifications

  Chef::Log.debug("Looking for templates in #{base_dir}")
  Find.find(base_dir) do |path|
    next unless path =~ /\.erb$/
    # Ignore these things (take as attribute and loop through array of ignores)
    #next if path =~ /something_to_ignore$/

    Chef::Log.debug("Processing file #{path}")
    target = path.sub(/\.erb$/,'')
    Chef::Log.debug("Target is #{target}")
    erb = Erubis::Eruby.new(::File.read(path))
    old = ::File.read(target) rescue nil
    begin
      new = erb.evaluate(variables)
    rescue NameError
      Chef::Log.debug("Unable to process template: #{path}")
    rescue RuntimeError
      Chef::Log.debug("Ignoring file #{path} due to RuntimeError")
    rescue LocalJumpError
      Chef::Log.debug("Ignoring file #{path} due to LocalJumpError")
    rescue NoMethodError
      Chef::Log.debug("Looks like file doesn't exist yet")
    end
    if new != old then
      Chef::Log.info("Template contents changed, writing #{target}")
      ::File.open(target, "w").write(new)
      # Find a better way to preserve owner and set permissions
      #FileUtils.chown(node["project"]["user"], node["project"]["group"], target)
      #if target =~ /.\.sh$/i then
      #  FileUtils.chmod "ug=wrx,o=r", target
      #end
      changed = true
    end
  end
  if (changed == true) then
    new_resource.updated_by_last_action(true)
    Chef::Log.info("Templates updated")
  end
end
