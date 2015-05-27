require "./cerberus.rb"
require "zlib"

puts "Loading login page..."
login_details = get_login_details
puts "Got CSRF token: #{login_details[:csrf]}"
puts "Got cookie: #{login_details[:cookie]}"


puts "Logging in..."
cookie = login(login_details[:csrf], login_details[:cookie], "RamiLevi", "")

if (!cookie)
  puts "Failed to log in :("
else
  puts "Logged in!"

  puts "Got updated cookie: #{cookie}"
  puts "Requesting directory list..."
  files = get_file_listing(cookie)

  files.each_with_index do |filename, idx|
    if (filename.start_with?("Prices"))
      puts "Downloading file #{filename} (#{idx}/#{files.count})"
      file_data = download_file(cookie, filename)

      gz = Zlib::GzipReader.new(StringIO.new(file_data))
      buffer = gz.read

      File.open(filename + ".xml", "wb") do |f|
        f.write(buffer)
      end
      puts "Wrote file #{filename}"
    else
      puts "Skipped file #{filename}"
    end
  end
end
