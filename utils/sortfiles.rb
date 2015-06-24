path = "./files/"
files = Dir["#{path}*"]

def get_file_details(filename)
  match = /([a-zA-Z]+)([0-9]+)-(\d+)?-?(\d+)?/.match(filename)
  if (match)
    timestamp = (match[4] != nil ? match[4] : match[3])
    timestamp.insert(4, "-")
    timestamp.insert(7, "-")
    timestamp.insert(10, " ")
    timestamp.insert(13, ":")
    {
      type: match[1],
      chainId: match[2],
      storeId: (match[4] != nil ? match[3] : nil),
      timestamp: timestamp
    }
  end
end

all_details = []

files.each do |file|
  file = file.gsub(path, "")
  details = get_file_details(file)
  if (details)
    all_details.push(details)
  else
    puts "Can't parse #{file}"
  end
end

all_details = all_details.sort_by do |d|
  (d[:storeId] || "") + (d[:timestamp] || "") + (d[:type] || "")
end

all_details.each do |details|
  line = ""
  line += details[:type].ljust(20)
  line += details[:chainId].ljust(20)
  line += (details[:storeId] || "N/A").ljust(20)
  line += details[:timestamp].ljust(20)
  puts line
end
