require 'rubygems'
require 'media_wiki'
require 'prawn'

title = ARGV[0]
page_url = "https://wiki.chaosdorf.de/#{title.gsub(' ','_')}"
mw = MediaWiki::Gateway.new("https://wiki.chaosdorf.de/api.php")
templates = mw.get(title).gsub(/[\r\n]/,'').scan(/{{([^}}]*)}}/)
templates.each do |template|
  fields = template[0].split("|")
  type = fields.shift
  if type == "Resource"
    properties = fields.collect! do |field|
      property = field.split("=")
    end
    filename = title.downcase+".pdf"
    properties = Hash[properties]
    pdftitle = "#{properties['name']}"
    pdftext = "is #{properties['ownership']} by #{properties['contactnick']}.  Use #{properties['use']} for #{properties['description']}. Put into #{properties['location']}. If broken #{properties['broken']}. If annoying #{properties['annoying']}.\n Date: #{Date.today}"
    Prawn::Document.generate(filename, :margin => 10, :left_margin => 20, :page_size => [255,107], :format => :landscape ) do
      font "computerfont.ttf"
      font_size 14
      text pdftitle
      font "cpmono_v07.ttf"
      font_size 8
      text "\n"
      text pdftext
      font_size 6
      move_cursor_to(7)
      text page_url
    end
  end
end
