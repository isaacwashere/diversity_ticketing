if Rails.env.test? || Rails.env.development?
	ENV['TWITTER_CONSUMER_KEY'] ||= '123456'
	ENV['TWITTER_CONSUMER_SECRET'] ||= '123456'
	ENV['TWITTER_ACCESS_TOKEN'] ||= '1234556'
	ENV['TWITTER_ACCESS_SECRET'] ||= '123456'
end