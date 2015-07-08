require 'sinatra'
require 'json'

STORE_ID_KEY = 'store_id'
BARCODE_KEY = 'barcode'

HARDCODED_CHAIN = '7290492000005'
	
get '/itemsByStore.json' do
	return missing_parameter_error(STORE_ID_KEY).to_json unless params[STORE_ID_KEY]

  get_items_by_store(params[STORE_ID_KEY]).to_json
end

get '/itemsByStore.html' do
	return missing_parameter_error(STORE_ID_KEY).to_json unless params[STORE_ID_KEY]

  result = get_items_by_store(params[STORE_ID_KEY])
  items = []
  result.keys.each do |key|
    item = result[key]
    item[:barcode] = key
    items.push(item)
  end
  table_from_array(items)
end

get '/countryByStore.html' do
	return missing_parameter_error(STORE_ID_KEY).to_json unless params[STORE_ID_KEY]

  result = get_items_by_store(params[STORE_ID_KEY])

  items = Hash.new
  result.each_value do |value|
    items[value['manufacture_country']] = (items[value['manufacture_country']] || 0) + 1
  end
  rows = []
  items.keys.each do |key|
    rows.push({ country: key, num: items[key] })
  end

  rows = rows.sort_by do |item|
    item[:num]
  end

  table_from_array(rows)
end

get '/itemByBarcode.html' do
	return missing_parameter_error(BARCODE_KEY).to_json unless params[BARCODE_KEY]

  result = get_item_with_prices_by_barcode(params[BARCODE_KEY])
  prices = result[:prices]
  result.delete(:prices)

  output = table_from_hash(result)
  output << table_from_array(prices)
  output
end

def get_items_by_store(store_id)
	store_filename = "db/chains/#{HARDCODED_CHAIN}/stores/#{store_id}.json"
	return error_no_such_store(store_id).to_json unless File.exist? store_filename

	store_items_string = File.read store_filename
	store_items = JSON.parse store_items_string
		
	output = {}
	store_items.each do |item_barcode, price|
    item_hash = get_item_by_barcode(item_barcode)
		next unless item_hash
		item_hash['price'] = price
		output[item_barcode] = item_hash
	end

  output
end

def get_item_by_barcode(barcode)
  item_filename = "db/barcodes/#{barcode}.json"
  return nil unless File.exist? item_filename
  item_string = File.read item_filename
  JSON.parse(item_string)
end

def get_item_with_prices_by_barcode(barcode)
  item = get_item_by_barcode(barcode)
  if (item)
    item[:prices] = []
    Dir["db/chains/*/stores/*"].each do |filename|
      store_string = File.read(filename)
      store_hash = JSON.parse(store_string)
      if (store_hash[barcode])
        item[:prices].push({ store_id: filename, price: store_hash[barcode] })
      end
    end
  end
  item
end

def error_no_such_store(store_id)
	{
		error: "no such store with id  '#{store_id}'"
	}
end

def missing_parameter_error(param)
	{
		error: "Missing parameter '#{param}'"
	}
end

def thead_from_hash(hash)
  result = ""
  hash.keys.each do |key|
    result << "<th>#{key}</th>"
  end
  result
end

def table_from_array(array)
  result = "<table>"
  result << "<thead>#{thead_from_hash(array[0])}</thead>"
  result << "<tbody>"
  array.each do |item|
    result << "<tr>"
    item.keys.each do |key|
      result << "<td>#{item[key]}</td>"
    end
    result << "</tr>"
  end
  result << "</tbody>"
  result << "</table>"

  result
end

def table_from_hash(hash)
  result = "<table>"
  result << "<tbody>"
  hash.each do |key, value|
    result << "<tr><td>#{key}</td><td>#{value}</td>"
  end
  result << "</tbody>"
  result << "</table>"

  result
end
