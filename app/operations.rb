require_relative 'services/fetcher/main.rb'
require_relative 'services/read_item.rb'
require 'trollop'

class Operations
  def xml
    ChainFileDownloder.new.download_dor_alon
  end

  def parse_xml
  	ChainXMLParser.new.parse_chain_xml_files
  end
end

opts = Trollop::options do
  opt :xml, "download Dor Alon xml files"
  opt :parse, "Parse Chain xml files"
end

ops = Operations.new
ops.xml if opts[:xml] 
ops.parse_xml if opts[:parse]

