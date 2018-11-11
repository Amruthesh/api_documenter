require "api_documenter/railtie"
require "api_documenter/response_parser"

module ApiDocumenter
  def ApiDocumenter.init
    path = "#{Rails.root}/coverage/api_documenter/"
    if Dir.exists?(path)
      Dir.foreach(path){|file| File.delete("#{path}#{file}") if ![".", ".."].include?(file.to_s)}
    else
      Dir.mkdir(path)
    end
  end

  def ApiDocumenter.init_index
    path = "#{Rails.root}/coverage/api_documenter/"
    index_file_path = "#{File.dirname(__FILE__)}/templates/index.html"
    FileUtils.copy(index_file_path, path)
  end

  def ApiDocumenter.insert_link(row)
    path = "#{Rails.root}/coverage/api_documenter/index.html"
    pattern = '</table>'
    file = File.read(path).sub(/<\/table>\n/, "#{row}\n#{pattern}")
    File.write(path, file)
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
      path = "#{Rails.root}/coverage/api_documenter/#{example.file_path.gsub('./spec/controllers/', '').split(".").first}.html"
      ApiDocumenter::ResponseParser::write_api_format(path, contents)
      link_to_file = "<tr><td><a href='#{path}'>#{request.path}</a></td></tr>"
      ApiDocumenter.insert_link(link_to_file)
    end
  end
end