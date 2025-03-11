install instructions:

```
apt-get update
apt-get upgrade -Vy
apt install -y build-essential ruby ruby-dev libssl-dev
gem install redis -v 4.8.1
gem install hiredis
gem list --local | grep redis
> hello4.rb; pico hello4.rb
ruby hello4.rb redis:port
```
