require 'pandarus'
require 'json'

client = Pandarus::Client.new(
  prefix: "https://osu.instructure.com/api",
  token:"YOUR SECRET TOKEN GOES HERE"
)
course = 119661 # this is the course number

puts "Building readings..."

`cd readings; make all`

puts "Building problem sets..."

`cd problem-sets; make all`

puts "Uploading PDFs..."

readings = nil
for folder in client.list_all_folders_courses(course)
  readings = folder if folder.name == "readings"
end
if readings
  for i in 1..16 do
    filename = "readings/reading#{'%02d' % i}.pdf"
    result = client.mixed_request( :post, "/v1/courses/#{course}/files", {}, {"name": "reading#{'%02d' % i}.pdf", "size": File.size(filename), "content_type": "application/pdf", "parent_folder_path": "readings", "on_dupliate": "overwrite" } )
    upload_url = result["upload_url"]
    line = ""
    for k in result["upload_params"].keys
      line = line + " -F '#{k}=#{result["upload_params"][k]}'"
    end
    puts "  uploading #{filename}..."
    `curl -s #{upload_url} #{line} -F 'file=@#{filename}'`
  end
end

readings = nil
for folder in client.list_all_folders_courses(course)
  readings = folder if folder.name == "problem-sets"
end
if readings
  for i in 1..7 do
    filename = "problem-sets/set#{'%02d' % i}.pdf"
    result = client.mixed_request( :post, "/v1/courses/#{course}/files", {}, {"name": "set#{'%02d' % i}.pdf", "size": File.size(filename), "content_type": "application/pdf", "parent_folder_path": "problem-sets", "on_dupliate": "overwrite" } )
    upload_url = result["upload_url"]
    line = ""
    for k in result["upload_params"].keys
      line = line + " -F '#{k}=#{result["upload_params"][k]}'"
    end
    puts "  uploading #{filename}..."
    `curl -s #{upload_url} #{line} -F 'file=@#{filename}'`
  end
end

# after you run the above, you can find these file IDs from the Canvas
# course; the file IDs are stable even after uploading new versions.

links = ['',
         '39282405',
         '39282406',
         '39282408',
         '39282409',
         '39282410',
         '39282411',
         '39282412',
         '39282413',
         '39282414',
         '39282416',
         '39282417',
         '39282418',
         '39282419',
         '39282420',
         '39282421',
         '39282422',
        ]

for i in 1..16 do
  filename = "readings/reading#{'%02d' % i}.html"
  puts "  updating page #{filename}..."
  id = links[i]
  link = "<p><a id=\"#{id}\" class=\"instructure_file_link instructure_scribd_file\" href=\"https://osu.instructure.com/courses/#{course}/files/#{id}?wrap=1\" target=\"_blank\" rel=\"noopener\" data-canvas-previewable=\"true\">View as PDF</a></p>"
  client.update_create_page_courses(course, "readings-for-week-#{i}", { "wiki_page.title": "Readings for Week #{i}", "wiki_page.body": link + File.open(filename).read } )
end

for page in client.list_pages_courses(course)
  puts page.title
end

