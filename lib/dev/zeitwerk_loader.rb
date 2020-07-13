require "zeitwerk"
require_relative "config"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "janio_api" => "JanioAPI"
)
loader.push_dir("./lib")
loader.collapse("./lib/janio_api/resources")
loader.ignore("#{__dir__}/config.rb")
loader.ignore("./lib/janio_api/exceptions.rb")
loader.ignore("./lib/janio_api/services_list.rb")
loader.ignore("./lib/janio_api/postal_code_regex_list.rb")
loader.enable_reloading
# loader.log!
loader.setup

$__janio_api_loader__ = loader

def reload!
  $__janio_api_loader__.reload
  set_config
  true
end
