require "yaml"
require "netaddr"

cf1_subnets = []
cf1_start = NetAddr::CIDR.create("10.244.4.0/30")

128.times do
  cf1_subnets << cf1_start
  cf1_start = NetAddr::CIDR.create(cf1_start.next_subnet)
end

print YAML.dump(
  "networks" => [
    { "name" => "cf1",
      "subnets" => cf1_subnets.collect.with_index do |subnet, idx|
        { "cloud_properties" => {
            "name" => "random",
          },
          "range" => subnet.to_s,
          "reserved" => [subnet[1].ip],
          "static" => idx < 64 ? [subnet[2].ip] : [],
        }
      end
    }
  ])
