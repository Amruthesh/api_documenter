module ApiDocumenter
  module ResponseParser
    def self.format_builder(json)
      fmt = {}
      json.each do |k, v|
        fmt[k] = format_value(v)
      end
      fmt
    end

    def self.format_value(val)
      klass = val.class
      return klass if is_basic_data_structure?(val)
      return format_builder(val) if klass == Hash
      return 'Unsupported data type' unless klass == Array
      [format_value(val.first)]
    end

    def self.is_basic_data_structure?(val)
      [String, TrueClass, FalseClass, NilClass, Symbol, Fixnum].include?(val.class)
    end

    def self.is_controller_example?(example)
      example.file_path.start_with?('./spec/controllers')
    end

    def self.build_metadata(example, request)
      all_files_path = "#{Rails.root}/coverage/api_documenter/index.html"
      html = "<body><div style='background: #e7fbc0;padding: 20px;'><a style='color: #2396de;font-size: 1.25em;' href='#{all_files_path}'>Back to all APIs list</a><br/><br/><span style='color: green;font-size: 2em;'>File Path: #{example.file_path}<br/>[#{request.method.upcase}] #{request.path}</span></div>"
    end

    def self.pretty_format(h)
      formatted_output = "<div style='background-color: #f3f3f3;padding: 10px; font-family: monospace; font-size: 1.25em;'><br/>"
      str = h.to_s
      tab_count = 1
      formatted_output += "#{str[0]}<br/>"
      current = "&nbsp;&nbsp;&nbsp;&nbsp;"*tab_count
      (str.length-1).times do |i|
        current_char = str[i+1]
        next if current_char == ' '
        next_char = str[i+2]
        current += current_char
        tab_count += 1 if ['{', '['].include?(current_char)
        tab_count -= 1 if next_char != ',' and (['}', ']'].include?(current_char) or [']', '}'].include?(next_char)) and tab_count > 0
        if next_char != ',' and ['{', '[', '}', ']', ','].include?(current_char) or [']', '}'].include?(next_char)
          formatted_output += (current + '<br/>')
          current = "&nbsp;&nbsp;&nbsp;&nbsp;"*tab_count
        end
      end
      formatted_output += "</div></body>"
      formatted_output
    end

    def self.write_api_format(path, contents)
      File.open(path, 'w+') { |f| f.write(contents) }
    end
  end
end