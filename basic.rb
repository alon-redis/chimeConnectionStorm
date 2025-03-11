require 'redis'
require 'securerandom'

# Function to parse host:port string
def parse_host_port(input)
  host, port = input.split(':')
  port = port.to_i
  [host, port]
end

# Function to generate random 25-byte string
def generate_random_string(size = 25)
  SecureRandom.hex(size / 2).slice(0, size)
end

# Get Redis connection string from command-line argument
if ARGV.empty?
  puts "Usage: ruby hello4.rb <host:port>"
  exit 1
end

connection_string = ARGV[0]

# Parse the input
host, port = parse_host_port(connection_string)

# Open a high-performance connection to Redis
redis = Redis.new(
  host: host, 
  port: port,
  timeout: 1.0,
  reconnect_attempts: 3,
  driver: :hiredis,
  ssl: false,
  db: 0
)

# Perform 2 write requests
2.times do |i|
  key = "key#{i + 1}"
  value = generate_random_string()
  redis.set(key, value)
  puts "Write #{i + 1}: SET #{key} = #{value}"
end

# Perform 8 read requests
8.times do |i|
  key = "key#{(i % 2) + 1}"  # Alternates between key1 and key2
  value = redis.get(key)
  puts "Read #{i + 1}: GET #{key} = #{value}"
end
