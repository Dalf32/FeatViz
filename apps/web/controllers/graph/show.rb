module Web
  module Controllers
    module Graph
      class Show
        include Web::Action

        def call(_params)
          graph_data = SessionDataRepository.new.graph_for_id(session.id.to_s)
          title = /<title>(.*)<\/title>/.match(graph_data)[1]

          MiniMagick.logger.level = Logger::DEBUG if configatron.debug_magick
          MiniMagick::Tool::Convert.new.tap do |convert|
            convert.font("#{configatron.magick_font}") if configatron.has_key?(:magick_font)
            convert << 'svg:-'
            convert << 'png:-'
          end.call(stdin: graph_data) do |graph_png_data, _err, _status|
            self.body = graph_png_data
            self.headers.merge!(
              {
                'Content-Length' => graph_png_data.length.to_s,
                'Content-Type' => 'image/png',
                'Content-Disposition' => "attachment; filename=\"#{title}.png\""
              }
            )
          end
        end
      end
    end
  end
end
