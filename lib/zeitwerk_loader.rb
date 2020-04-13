require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "janio_api" => "JanioAPI"
)
loader.push_dir("lib")
loader.collapse("lib/janio_api/resources")
# loader.log!
loader.setup
