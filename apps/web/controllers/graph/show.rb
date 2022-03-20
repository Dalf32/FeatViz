module Web
  module Controllers
    module Graph
      class Show
        include Web::Action

        def call(_params)
          graph_data = SessionDataRepository.new.graph_for_id(session.id.to_s)
          title = /<title>(.*)<\/title>/.match(graph_data)[1]

          graph_svg = Magick::Image.from_blob(graph_data).first
          graph_png_data = graph_svg.to_blob { |img| img.format = 'PNG' }

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
