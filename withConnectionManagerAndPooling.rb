require 'redis'
require 'connection_pool'
require 'securerandom'

# RedisManager: Manages connection pools for Redis
class RedisManager
  @connection_pool_cache = {}

  class << self
    attr_accessor :connection_pool_cache
  end

  def self.build_connection_pool(host, port, pool_size)
    ConnectionPool.new(size: pool_size) do
      Redis.new(
        host: host,
        port: port,
        timeout: 1.0,
        reconnect_attempts: 3,
        ssl: false,
        db: 0
      )
    end
  end

  def self.connection_pool_for(host_port, pool_size = 10)
    host, port = host_port.split(':')
    connection_pool_cache[host_port] ||= build_connection_pool(host, port, pool_size)
  end
end

# Function to generate random 25-byte string
def generate_random_string(size = 25)
  SecureRandom.hex(size / 2).slice(0, size)
end

# Main execution
if ARGV.empty?
  puts "Usage: ruby hello4.rb <host:port>"
  exit 1
end

connection_string = ARGV[0]
pool_size = ENV.fetch('REDIS_POOL_SIZE', 20).to_i

# Get connection pool from manager
redis_pool = RedisManager.connection_pool_for(connection_string, pool_size)

# Perform 2 write requests
2.times do |i|
  redis_pool.with do |conn|
    key = "key#{i + 1}"
    value = generate_random_string()
    conn.set(key, value)
    puts "Write #{i + 1}: SET #{key} = #{value}"
  end
end

# Perform 8 read requests
8.times do |i|
  redis_pool.with do |conn|
    key = "key#{(i % 2) + 1}" # Alternates between key1 and key2
    value = conn.get(key)
    puts "Read #{i + 1}: GET #{key} = #{value}"
  end
end
