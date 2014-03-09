require 'aws-sdk'

AWS.config(
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
)

object = AWS::S3.new.buckets[ARGV[0]].objects[ARGV[1]]
puts object.url_for(:read, :expires => 172800)
