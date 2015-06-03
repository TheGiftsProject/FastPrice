require 'nokogiri'
require 'awesome_print'
require 'json'

items = []

prices_file = './files/PriceFull7290492000005-501-201506030010'

def convert_item(item_from_xml)
	item = {}
	item['price_update_date'] = item_from_xml['PriceUpdateDate']
	item['item_code'] = item_from_xml['ItemCode']
	item['item_type'] = item_from_xml['ItemType']
	item['item_name'] = item_from_xml['ItemName']
	item['manufacturer_name'] = item_from_xml['ManufacturerName']
	item['manufacture_country'] = item_from_xml['ManufactureCountry']
	item['manufacturer_item_description'] = item_from_xml['ManufacturerItemDescription']
	item['unit_qty'] = item_from_xml['UnitQty']
	item['unit_of_measure'] = item_from_xml['UnitOfMeasure']
	item['b_is_weighted'] = item_from_xml['bIsWeighted']
	item['qty_in_package'] = item_from_xml['QtyInPackage']
	item['item_price'] = item_from_xml['ItemPrice']
	item['unit_of_measure_price'] = item_from_xml['UnitOfMeasurePrice']
	item['allow_discount'] = item_from_xml['AllowDiscount']
	item['item_id'] = item_from_xml['ItemId']
	item['item_status'] = item_from_xml['ItemStatus']
	item
end

def read_item(item_xml)
	item_from_xml = {}
	item_xml.children.each do |element|
		item_from_xml[element.name] = element.content if (element.name != 'text')
	end
	convert_item(item_from_xml)
end

def print_item(item)
	ap item
end

def read_prices_file(prices_xml)
	# save common data
	chain_id = prices_xml.css("ChainId").text
	store_id = prices_xml.css("StoreId").text
	
	# iterate files
	prices_xml.css("Items Item").each do |item_xml|
		item = read_item(item_xml)
		yield item.merge({
			chain_id: chain_id,
			store_id: store_id
		})
	end
end

Dir["files/PriceFull*"].each_with_index do |filename, index|
	puts "processing file #{index + 1}: #{filename}"
	prices_file_xml = Nokogiri::XML(File.read(filename))

	read_prices_file(prices_file_xml) {|item| items << item}
end
puts items.count

File.open 'db/items.json', 'w' do |file|
	file.write items.to_json
end


