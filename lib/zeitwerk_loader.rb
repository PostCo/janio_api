require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "janio_api" => "JanioAPI"
)
loader.collapse("./lib/janio_api/resources")
loader.enable_reloading
loader.tag = "janio_api_gem"
# loader.log!
loader.setup

if ENV["JANIO_API_GEM_ENV"] == "development"
  $__janio_api_loader__ = loader
  def reload!
    $__janio_api_loader__.reload
  end
end
