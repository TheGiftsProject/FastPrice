require "awesome_print"
require "nokogiri"

class Chain
  attr_accessor :id
  attr_accessor :name
  attr_accessor :sub_chains
end

class SubChain
  attr_accessor :id
  attr_accessor :name
  attr_accessor :stores
end

class Store
  attr_accessor :id
  attr_accessor :bikoret_no
  attr_accessor :type
  attr_accessor :name
  attr_accessor :address
  attr_accessor :city
  attr_accessor :zip_code
end

def parse_stores_file(filename)
  f = File.open(filename)
  xml = Nokogiri::XML(f)
  f.close
  chain = Chain.new
  chain.id = xml.xpath("/Root/ChainId")[0].text
  chain.name = xml.xpath("/Root/ChainName")[0].text
  chain.sub_chains = xml.xpath("/Root/SubChains/SubChain").map do |subchain|
    sc = SubChain.new
    sc.id = subchain.xpath("SubChainId").text
    sc.name = subchain.xpath("SubChainName").text
    sc.stores = subchain.xpath("Stores/Store").map do |store|
      st = Store.new
      st.id = store.xpath("StoreId").text
      st.bikoret_no = store.xpath("BikoretNo").text
      st.type = store.xpath("StoreType").text
      st.name = store.xpath("StoreName").text
      st.address = store.xpath("Address").text
      st.city = store.xpath("City").text
      st.zip_code = store.xpath("ZipCode").text
      st
    end
    sc
  end
  chain
end

def print_chain(chain)
  puts "<!DOCTYPE html>"
  puts "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"></head><body>"
  puts "<h1>Chain #{chain.id}: #{chain.name}</h1>"
  chain.sub_chains.each do |subchain|
    puts "<h2>Subchain #{subchain.id}: #{subchain.name}</h2>"
    puts "<table><thead><th>id</th><th>name</th><th>type</th><th>address</th><th>city</th><th>zipcode</th></thead>"
    subchain.stores.each do |store|
      puts "<tr>"
      puts "<td>#{store.id}</td>"
      puts "<td>#{store.name}</td>"
      puts "<td>#{store.type}</td>"
      puts "<td>#{store.address}</td>"
      puts "<td>#{store.city}</td>"
      puts "<td>#{store.zip_code}</td>"
      puts "</tr>"
    end
    puts "</table>"
  end
  puts "</body></html>"
end

chain = parse_stores_file("./files/Stores7290492000005-201506030700.xml")
print_chain(chain)
