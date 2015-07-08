require 'nokogiri'
require 'awesome_print'
require 'json'
require 'fileutils'

store_items = {}

ITEM_PRICE_UPDATE_DATE = 'price_update_date'
ITEM_PRICE = 'item_price'
ITEM_CODE = 'item_code'

FILE_WRITE_OPTION = "w:UTF-8"

BARCODE_FILE_REJECTED_FIELDS = [ITEM_PRICE_UPDATE_DATE, ITEM_PRICE]

def convert_item(item_from_xml)
	item = {}
	item[ITEM_PRICE_UPDATE_DATE] = item_from_xml['PriceUpdateDate']
	item[ITEM_CODE] = item_from_xml['ItemCode']
	item['item_type'] = item_from_xml['ItemType']
	item['item_name'] = item_from_xml['ItemName']
	item['manufacturer_name'] = item_from_xml['ManufacturerName']
	item['manufacture_country'] = item_from_xml['ManufactureCountry']
	item['manufacturer_item_description'] = item_from_xml['ManufacturerItemDescription']
	item['unit_qty'] = item_from_xml['UnitQty']
	item['unit_of_measure'] = item_from_xml['UnitOfMeasure']
	item['b_is_weighted'] = item_from_xml['bIsWeighted']
	item['qty_in_package'] = item_from_xml['QtyInPackage']
	item[ITEM_PRICE] = item_from_xml['ItemPrice']
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

def store_id(chain_id, store_id)
	"#{store_id}_#{chain_id}"
end

def read_prices_file(prices_xml)
	# iterate files
	prices_xml.css("Items Item").each do |item_xml|
		item = read_item(item_xml)
		yield item
	end
end


def write_barcode_file(item)
	filename = "db/barcodes/#{item['item_code']}.json"

	return if File.exist? filename
	
	FileUtils.mkpath 'db/barcodes' unless File.exist? 'db/barcodes'
	File.open filename, FILE_WRITE_OPTION do |file|
		barcode_json = item.reject {|k, _| BARCODE_FILE_REJECTED_FIELDS.include?(k) }
 		file.write barcode_json.to_json
 	end	
end

def write_store_file(store_id, chain_id, store_items)
	FileUtils.mkpath "db/chains/#{chain_id}/stores/" unless File.exist? "db/chains/#{chain_id}/stores/"
	File.open "db/chains/#{chain_id}/stores/#{store_id}.json", FILE_WRITE_OPTION do |file|
 		file.write store_items.to_json
 	end	
end

def add_item_to_store(item, store_items)
	return if store_items[item[ITEM_CODE]] != nil
	store_items[item[ITEM_CODE]] = item[ITEM_PRICE]
end

Dir["files/PriceFull*"].each_with_index do |filename, index|
	puts "processing file #{index + 1}: #{filename}"
	prices_file_xml = Nokogiri::XML(File.read(filename))

	chain_id = prices_file_xml.css("ChainId").text
	store_id = prices_file_xml.css("StoreId").text

	read_prices_file(prices_file_xml) do |item| 
		write_barcode_file(item)
		add_item_to_store(item, store_items)
	end

	write_store_file(store_id, chain_id, store_items)
end

