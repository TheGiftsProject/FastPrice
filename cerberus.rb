require 'HTTParty'
require 'nokogiri'
require 'json'


response = HTTParty.get('https://url.publishedprices.co.il/login')
doc = Nokogiri::HTML(response)
csrf_node = doc.css("input[name='csrftoken']")
csrf = csrf_node.first.attribute('value')
cookie = response.headers['Set-Cookie'].split(";").first

sleep(1)

username = 'readonly'
password = '123456'
response = HTTParty.post('https://url.publishedprices.co.il/login/user',
                         body: {
                             'csrftoken' => csrf,
                             'username' => username,
                             'password' => password,
                             'Submit' => 'Sign in'
                         },
                         headers: {
                             'Cookie' => cookie,
                             'Host' => 'url.publishedprices.co.il',
                             'Connection' => 'keep-alive',
                            'Content-Length' =>'103',
                            'Cache-Control' => 'max-age=0',
                            'Accept' =>'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                            'Origin' =>'https://url.publishedprices.co.il',
                            'User-Agent' =>'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.152 Safari/537.36',
                            'Content-Type' =>'application/x-www-form-urlencoded',
                            'Referer' =>'https://url.publishedprices.co.il/login',
                            'Accept-Encoding' =>'gzip, deflate',
                            'Accept-Language' => 'en-US,en;q=0.8,he;q=0.6'
                         },
                         follow_redirects: false
)

logged_in = response.headers['Location'] == '/file'

if (!logged_in)
  puts "Not logged in"
  return
end

cookie = response.headers['Set-Cookie'].split(";").first
response = HTTParty.get('https://url.publishedprices.co.il/file/ajax_dir', query: {'iDisplayLength' => 250}, headers: {'Cookie' => cookie})
valid_stores = ['RamiLevi']

valid_stores.each do |store|
  response = HTTParty.get('https://url.publishedprices.co.il/file/ajax_dir', query: {'iDisplayLength' => 250, 'cd' => "/#{store}"}, headers: {'Cookie' => cookie})
  puts "#{response}"
end

