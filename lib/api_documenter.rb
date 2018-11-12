require "api_documenter/railtie"
require "api_documenter/response_parser"

module ApiDocumenter
  def ApiDocumenter.init
    path = "#{Rails.root}/coverage/api_documenter/"
    FileUtils.rm_r(path) if Dir.exists?(path)
    Dir.mkdir(path)
    FileUtils::mkdir_p(path + "api/v1")
  end

  def ApiDocumenter.init_index
    path = "#{Rails.root}/coverage/api_documenter/"
    index_file_path = "#{File.dirname(__FILE__)}/templates/index.html"
    FileUtils.copy(index_file_path, path)
  end

  def ApiDocumenter.insert_link(row)
    path = "#{Rails.root}/coverage/api_documenter/index.html"

    file = File.readlines(path)
    index = file.index("<table>\n")
    file.insert(index+1, row)
    File.write(path, file.join.to_s)
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    ApiDocumenter.init
    ApiDocumenter.init_index
  end

  config.after(:each, :inspect_response) do |example|
  	if ApiDocumenter::ResponseParser::is_controller_example?(example)
      body = JSON.parse(response.body) rescue {UnsupportedResponseBody: :Fail}
      contents = ApiDocumenter::ResponseParser::build_metadata(example, request)
      contents += ApiDocumenter::ResponseParser::pretty_format(ApiDocumenter::ResponseParser::format_builder(body))
      path = "#{Rails.root}/coverage/api_documenter/#{request.path.gsub('/', '-')}.html"
      ApiDocumenter::ResponseParser::write_api_format(path, contents)
      link_to_file = "<tr><td><a href='#{path}'>#{request.path}</a></td></tr>"
      ApiDocumenter.insert_link(link_to_file)
    end
  end
end