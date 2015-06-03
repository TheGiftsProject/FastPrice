require 'nokogiri'
require 'awesome_print'
require 'json'

items = {}

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

def store_id(chain_id, store_id)
	"#{store_id}_#{chain_id}"
end

def read_prices_file(prices_xml)
	# save common data
	chain_id = prices_xml.css("ChainId").text
	store_id = prices_xml.css("StoreId").text
	
	# iterate files
	prices_xml.css("Items Item").each do |item_xml|
		item = read_item(item_xml)
		merged_item = item.merge({'store_id' => store_id(store_id, chain_id)})
		yield merged_item
	end
end

def add_item_to_db(original_item, items)
	if items[original_item['item_code']] != nil
		item = items[original_item['item_code']]
		item.each_pair do |key, value|
			if key != 'item_price'
				item[key] << original_item[key] unless item[key].include? original_item[key]
			else
				item[key]["#{original_item['store_id']}"] = original_item[key]
			end
		end
	else
		item = original_item.clone
		items[item['item_code']] = item.each_pair do |key, value|
			if key != 'item_price'
				item[key] = [value]
			else
				item[key] = {"#{item['store_id']}" => value}
			end
		end
	end
end

Dir["files/PriceFull*"].each_with_index do |filename, index|
	puts "processing file #{index + 1}: #{filename}"
	prices_file_xml = Nokogiri::XML(File.read(filename))

	read_prices_file(prices_file_xml) {|item| add_item_to_db(item, items) }
	File.open 'db/items.json', 'w' do |file|
		file.write items.to_json
	end
end

