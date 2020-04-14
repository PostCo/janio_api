require "zeitwerk"

$__janio_api_loader__ = Zeitwerk::Loader.for_gem
$__janio_api_loader__.inflector.inflect(
  "janio_api" => "JanioAPI"
)
$__janio_api_loader__.push_dir("lib")
$__janio_api_loader__.collapse("lib/janio_api/resources")
$__janio_api_loader__.enable_reloading
# loader.log!
$__janio_api_loader__.setup
def reload!
  $__janio_api_loader__.reload
end
