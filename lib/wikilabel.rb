require 'rubygems'
require 'media_wiki'
require 'prawn'
require 'tempfile'

class WikiLabel
  def self.call(env)
    request = Rack::Request.new(env)
    title = request.params['w']
    filename = 0
    page_url = "https://wiki.chaosdorf.de/#{title.gsub(' ','_')}"
    labeloptions = {:margin => 12, :left_margin => 20, :page_size => [255,107], :format => :landscape}
    mw = MediaWiki::Gateway.new("https://wiki.chaosdorf.de/api.php")
    site = mw.get(title)
    if site
      tempfile = Tempfile.new('tmp')
      templates = site.gsub(/[\r\n]/,'').scan(/{{([^}}]*)}}/)
      templates.each do |template|
        fields = template[0].split("|")
        properties = fields.collect! do |field|
          property = field.split("=")
        end
        properties = Hash[properties]
        type = fields.shift.first
        case type
        when "Resource"
          pdftitle = "#{properties['name']}"
          usage = 'unknown'
          ownership = 'unknown'
          case properties['ownership']
          when 'club'
            ownership = "collective property"
          when 'private'
            ownership = "private property of #{properties['contactnick']}"
          when 'lent'
            ownership = "lent by #{properties['contactnick']}"
          end
          case properties['use']
          when 'free'
            usage = 'freely'
          when 'ask'
            usage = 'with permission'
          when 'rtfm'
            usage = 'after reading manual'
          when 'no'
            usage = 'not at all'
          when 'careful'
            usage = 'carefully'
          when 'payment'
            usage = 'after donation'
          end
          pdftext = "#{properties['description']}\nIs #{ownership}. " +
            "Use #{usage}. Put into #{properties['location']}. "
          if properties['broken']
            pdftext << "If broken #{properties['broken']}. "
          end
          if properties['annoying']
            pdftext << "If annoying #{properties['annoying']}."
          end
          pdftext << "\nDate: #{Date.today}"
          Prawn::Document.generate(tempfile, labeloptions) do
            font "fonts/computerfont.ttf"
            font_size 14
            text pdftitle
            font "fonts/cpmono_v07.ttf"
            font_size 8
            text "\n"
            text pdftext
            font_size 6
            move_cursor_to(7)
            text page_url
          end
        when "Book"
          Prawn::Document.generate(tempfile, labeloptions) do
            font "computerfont.ttf"
            font_size 10
            text "This book belongs into the Chaosdorf Bookshelf.\nRead it, comment it, share it!"
            font "cpmono_v07.ttf"
            font_size 8
            text "\n"
            case properties['ownership']
            when 'private'
              text "Please ask #{properties['owner']} for permission and put your name into the wiki before borrowing it. After reading, please return it immediately."
            when 'lent'
              text "Please put your name into the wiki before borrowing it. After reading, please return it immediately. The owner is #{properties['owner']}."
            when 'club'
              text "Please put your name into the wiki before borrowing it. After reading, please return it immediately. It has been donated to the club."
            end
            font_size 5
            move_cursor_to(7)
            text page_url
          end
        else
          puts "Warning: #{type} is an unknown object type. Currently, only resources and books are supported."
        end
      end
      return [200, {"Content-Type" => "application/pdf"}, [tempfile.read]]
    else
      return [404, {"Content-Type" => "text/plain"}, ["Page #{title} could not be found in the Chaosdorf Wiki"]]
    end
  end
end


