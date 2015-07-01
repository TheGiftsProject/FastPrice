require "./cerberus.rb"
require "./thread_pool.rb"
require "zlib"

puts "Loading login page..."
login_details = get_login_details
puts "Got CSRF token: #{login_details[:csrf]}"
puts "Got cookie: #{login_details[:cookie]}"


puts "Logging in..."
cookie = login(login_details[:csrf], login_details[:cookie], "doralon", "")

if (!cookie)
  puts "Failed to log in :("
else
  puts "Logged in!"

  puts "Got updated cookie: #{cookie}"
  puts "Requesting directory list..."
  files = get_file_listing(cookie)

  download_tasks = []

  Dir.mkdir './files' unless File.exist? './files'
  files.each_with_index do |filename, idx|
    download_tasks.push(Proc.new {
      attempt = 0
      success = false
      while (!success) do
        begin
          puts "Downloading file #{filename} (#{idx}/#{files.count}) Attempt #{attempt}"
          file_data = download_file(cookie, filename)

          if (filename.end_with?(".gz"))
            gz = Zlib::GzipReader.new(StringIO.new(file_data))
            buffer = gz.read
            filename = filename[0..-4]
          else
            buffer = file_data
          end

          File.open("./files/" + filename, "wb") do |f|
            f.write(buffer)
          end
          puts "Wrote file #{filename}"
          success = true
        rescue
          attempt += 1
        end
      end

      File.open("./files/" + filename, "wb") do |f|
        f.write(buffer)
      end
      puts "Wrote file #{filename}"
    })
  end

  parallelize(download_tasks, 100)
end
