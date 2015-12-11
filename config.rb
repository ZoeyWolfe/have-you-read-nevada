require "uglifier"

# Minimum Sass number precision required by bootstrap-sass
::Sass::Script::Number.precision = [10, ::Sass::Script::Number.precision].max

# Add Bower to sprockets
after_configuration do
  sprockets.append_path File.join root.to_s, "bower_components"
end

# Integrate Dotenv
activate :dotenv

# Activate directory indexes for pretty urls
activate :directory_indexes

# Activate gzip compression
activate :gzip

# Set url root
set :url_root, build? ? ENV["URL_PRODUCTION"] : ENV["URL_DEVELOPMENT"]

# Asset paths
set :css_dir,     "stylesheets"
set :js_dir,      "javascripts"
set :images_dir,  "images"

# Prevent asset concatenation in development
set :debug_assets, true

# Define 404 page
page "/404.html", :directory_index => false

# Reload the browser in development automatically whenever files change
configure :development do
  activate :livereload
end

# Deployment via middleman-deploy.
# Usage:
# $ rake deploy
activate :deploy do |deploy|
  deploy.build_before = true
  deploy.method       = :git
end

# Build-specific configuration
configure :build do

  # For example, change the Compass output style for deployment
  activate :minify_css, inline: true

  # Minify Javascript
  activate :minify_javascript, inline: true, compressor: Uglifier.new(mangle: false, comments: :none)

  # Minify HTML
  activate :minify_html, remove_comments: false

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets
end

helpers do
  # A simple helper to move partials to their own directory. There's probably a
  # better way to do this, but ah well.
  def partial(template, options = {})
    render_partial "partials/#{template}", options
  end

  # Helper which generates <html> tag with conditional IE classes
  # https://gist.github.com/SteveBenner/a71f41e175f135b7d69b
  def conditional_html_tags(ie_versions, attributes={})
    # Create an array from given range that allows us to generate the code via simple iteration
    ie_versions = ie_versions.to_a.unshift(ie_versions.min - 1).push(ie_versions.max + 1)
    # Classes from user-provided String or Array are appended after the default ones
    extra_classes = attributes.delete(:class) { |key| attributes[key.to_s] }

    commented_html_tags = ie_versions.collect { |version|
      # A 'lt-ie' class is added for each supported IE version higher than the current one
      ie_classes  = (version+1..ie_versions.max).to_a.reverse.collect { |j| "lt-ie#{j}" }
      class_str   = ie_classes.unshift('no-js').push(extra_classes).compact.join ' '
      attr_str    = attributes.collect { |name, value| %Q[#{name.to_s}="#{value}"] }.join ' '
      html_tag    = %Q[<html class="#{class_str}"#{' ' unless attr_str.empty?}#{attr_str}>]
      # The first and last IE conditional comments are unique
      version_str = case version
        when ie_versions.min then
          "lt IE #{version + 1}"
        # Side effects in a `case` statement are rarely a good idea, but it makes sense here
        when ie_versions.max
          # This is rather crucial; the last HTML tag must be uncommented in order to be recognized
          html_tag.prepend('<!-->').concat('<!--') # Note that both methods are destructive
          "gt IE #{version - 1}"
        else "IE #{version}"
      end
      %Q[<!--[if #{version_str}]#{html_tag}<![endif]-->]
    }.flatten * $/
    # Return the output from given Slim blockm, wrapped in the code for commented HTML tags
    [commented_html_tags, yield, $/, '</html>'].join
  end
end
