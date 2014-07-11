class << self
  def geo_data_fixture
    puts "creating GeoData"
    data = GeoData.find_or_create_by(name: "OKFN - Open Knowledge Foundation")
    data.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam tincidunt congue enim, ut porta lorem lacinia consectetur. Donec ut libero sed arcu vehicula ultricies a non tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut gravida lorem. Ut turpis felis, pulvinar a semper sed, adipiscing id dolor. Pellentesque auctor nisi id magna consequat sagittis. Curabitur dapibus enim sit amet elit pharetra tincidunt feugiat nisl imperdiet. Ut convallis libero in urna ultrices accumsan. Donec sed odio eros. Donec viverra mi quis quam pulvinar at malesuada arcu rhoncus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In rutrum accumsan ultricies. Mauris vitae nisi at sem facilisis semper ac in est."
    data.location = "GEOMETRYCOLLECTION (POINT (-46.747319110450746 -23.56587791267138))"
    data.contacts = {"city" => "São Paulo", "site" => "br.okfn.br", "phone" => "98765456789", "address" => "Av Paulista, 42"}
    data.tags = ["open data", "ngo", "hacking"]
    data.save

    data = GeoData.find_or_create_by(name: "OKFN-BR - Open Knowledge Foundation Brazil")
    data.description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a diam lectus. Sed sit amet ipsum mauris. Maecenas congue ligula ac quam viverra nec consectetur ante hendrerit. Donec et mollis dolor. Praesent et diam eget libero egestas mattis sit amet vitae augue. Nam tincidunt congue enim, ut porta lorem lacinia consectetur. Donec ut libero sed arcu vehicula ultricies a non tortor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean ut gravida lorem. Ut turpis felis, pulvinar a semper sed, adipiscing id dolor. Pellentesque auctor nisi id magna consequat sagittis. Curabitur dapibus enim sit amet elit pharetra tincidunt feugiat nisl imperdiet. Ut convallis libero in urna ultrices accumsan. Donec sed odio eros. Donec viverra mi quis quam pulvinar at malesuada arcu rhoncus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In rutrum accumsan ultricies. Mauris vitae nisi at sem facilisis semper ac in est."
    data.location = "GEOMETRYCOLLECTION (POINT (-46.744319110450746 -23.563487791267138))"
    data.contacts = {"city" => "São Paulo", "site" => "br.okfn.br", "phone" => "98765456789", "address" => "Av Paulista, 42"}
    data.tags = ["open data", "ngo", "hacking"]
    data.save
  end
end

geo_data_fixture
