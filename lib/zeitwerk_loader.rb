require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "janio_api" => "JanioAPI"
)
loader.collapse("./lib/janio_api/resources")
loader.ignore("#{__dir__}/dev_config.rb")
loader.enable_reloading
# loader.log!
loader.setup

$__janio_api_loader__ = loader

def reload!
  $__janio_api_loader__.reload
  set_config
  true
end
