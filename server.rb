require 'sinatra'
require 'json'

STORE_ID_KEY = 'store_id'

HARDCODED_CHAIN = '7290492000005'
	
get '/itemsByStore' do
	return missing_parameter_error(STORE_ID_KEY).to_json unless params[STORE_ID_KEY]

	store_filename = "db/chains/#{HARDCODED_CHAIN}/stores/#{params[STORE_ID_KEY]}.json"
	return error_no_such_store(params[STORE_ID_KEY]).to_json unless File.exist? store_filename

	store_items_string = File.read store_filename
	store_items = JSON.parse store_items_string

	
	store_items.to_json
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