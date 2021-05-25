use Test::More tests => 76;
use Cwd;
use URI::Escape;
use MolochTest;
use JSON;
use Test::Differences;
use Data::Dumper;
use strict;

my $pwd = "*/pcap";

sub testMulti {
   my ($json, $mjson, $url) = @_;

   my @items = sort({$a->{name} cmp $b->{name}} @{$json->{items}});
   my @mitems = sort({$a->{name} cmp $b->{name}} @{$mjson->{items}});

   eq_or_diff($mjson->{map}, $json->{map}, "single doesn't match multi map for $url", { context => 3 });
   eq_or_diff($mjson->{graph}, $json->{graph}, "single doesn't match multi graph for $url", { context => 3 });
   eq_or_diff(\@mitems, \@items, "single doesn't match multi graph for $url", { context => 3 });

   return $json;
}

sub get {
my ($url) = @_;

#   diag $url;
    my $json = viewerGet($url);
    my $mjson = multiGet($url);

    $json = testMulti($json, $mjson, $url);

    return $json
}

sub post {
    my ($url, $content) = @_;

    my $json = viewerPost($url, $content);
    my $mjson = multiPost($url, $content);

    $json = testMulti($json, $mjson, $url);

    return $json;
}

esGet("/_refresh");

my ($json, $mjson, $pjson);

#node
    $json = get("/spigraph.json?map=true&date=-1&field=node&expression=" . uri_escape("file=$pwd/bigendian.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    $pjson = post("/api/spigraph", '{"map":true, "date":-1, "field":"node", "expression":"file=' . $pwd . '/bigendian.pcap|file=' . $pwd . '/socks-http-example.pcap|file=' . $pwd . '/bt-tcp.pcap"}');
    eq_or_diff($json, $pjson, "GET and POST versions of spigraph endpoint are not the same");
    eq_or_diff($json->{map}, from_json('{"dst":{"US": 3, "CA": 1}, "src":{"US": 3, "RU":1}, "xffGeo":{}}'), "map field: no");
    eq_or_diff($json->{graph}->{sessionsHisto}, from_json('[["1335956400000", 1], ["1386003600000", 3], [1387742400000, 1], [1482552000000, 1]]'), "sessionsHisto field: node");
    eq_or_diff($json->{graph}->{"source.packetsHisto"}, from_json('[["1335956400000", 2], ["1386003600000", 26], [1387742400000, 3], [1482552000000, 3]]'), "source.packetsHisto field: node");
    eq_or_diff($json->{graph}->{"destination.packetsHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 20], [1387742400000, 1], [1482552000000, 1]]'), "destination.packetsHisto field: node");
    eq_or_diff($json->{graph}->{"client.bytesHisto"}, from_json('[["1335956400000", 128], ["1386003600000", 486], [1387742400000, 68], [1482552000000, 68]]'), "client.bytesHisto field: node");
    eq_or_diff($json->{graph}->{"server.bytesHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 4801], [1387742400000, 0], [1482552000000, 0]]'), "server.bytesHisto field: node");
    eq_or_diff($json->{items}, from_json('[{"totDataBytesHisto":5551,"client.bytesHisto":750,"server.bytesHisto":4801,"name":"test","network.bytesHisto":9261,"source.bytesHisto":2968,"destination.bytesHisto":6293,"network.packetsHisto":56,"source.packetsHisto":34,"destination.packetsHisto":22,"count":6,"map":{"xffGeo":{},"dst":{"CA":1,"US":3},"src":{"RU":1,"US":3}},"graph":{"destination.bytesHisto":[[1335956400000,0],[1386003600000,6145],[1387742400000,66],[1482552000000,82]],"source.packetsHisto":[[1335956400000,2],[1386003600000,26],[1387742400000,3],[1482552000000,3]],"xmax":1482552000000,"xmin":1335956400000,"sessionsTotal":6,"network.bytesTotal":9261,"totDataBytesTotal":5551,"network.packetsTotal":56,"destination.packetsHisto":[[1335956400000,0],[1386003600000,20],[1387742400000,1],[1482552000000,1]],"client.bytesHisto":[[1335956400000,128],[1386003600000,486],[1387742400000,68],[1482552000000,68]],"source.bytesHisto":[[1335956400000,196],[1386003600000,2238],[1387742400000,248],[1482552000000,286]],"server.bytesHisto":[[1335956400000,0],[1386003600000,4801],[1387742400000,0],[1482552000000,0]],"interval":3600,"sessionsHisto":[[1335956400000,1],[1386003600000,3],[1387742400000,1],[1482552000000,1]]},"sessionsHisto":6}]'), "items field: node", { context => 3 });
    cmp_ok ($json->{recordsTotal}, '>=', 194);
    cmp_ok ($json->{recordsFiltered}, '==', 6);

#tags
    $json = get("/spigraph.json?map=true&date=-1&field=tags&expression=" . uri_escape("file=$pwd/bigendian.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    eq_or_diff($json->{map}, from_json('{"dst":{"US": 3, "CA": 1}, "src":{"US": 3, "RU":1}, "xffGeo":{}}'), "map field: tags");
    eq_or_diff($json->{graph}->{sessionsHisto}, from_json('[["1335956400000", 1], ["1386003600000", 3], [1387742400000, 1], [1482552000000, 1]]'), "sessionsHisto field: tags");
    eq_or_diff($json->{graph}->{"source.packetsHisto"}, from_json('[["1335956400000", 2], ["1386003600000", 26], [1387742400000, 3], [1482552000000, 3]]'), "source.packetsHisto field: tags");
    eq_or_diff($json->{graph}->{"destination.packetsHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 20], [1387742400000, 1], [1482552000000, 1]]'), "destination.packetsHisto field: tags");
    eq_or_diff($json->{graph}->{"client.bytesHisto"}, from_json('[["1335956400000", 128], ["1386003600000", 486], [1387742400000, 68], [1482552000000, 68]]'), "client.bytesHisto field: tags");
    eq_or_diff($json->{graph}->{"server.bytesHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 4801], [1387742400000, 0], [1482552000000, 0]]'), "server.bytesHisto field: tags");
    cmp_ok ($json->{recordsTotal}, '>=', 194);
    cmp_ok ($json->{recordsFiltered}, '==', 6);

    my @items = sort({$a->{name} cmp $b->{name}} @{$json->{items}});
    eq_or_diff(\@items, from_json('[{"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"name":"byhost2","map":{"xffGeo":{},"src":{"US":3},"dst":{"US":3}},"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"count":3,"sessionsHisto":3,"graph":{"destination.bytesHisto":[[1386003600000,6145]],"source.bytesHisto":[[1386003600000,2238]],"xmin":1335956400000,"xmax":1482552000000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"destination.packetsHisto":[[1386003600000,20]],"client.bytesHisto":[[1386003600000,486]],"source.packetsHisto":[[1386003600000,26]],"interval":3600,"server.bytesHisto":[[1386003600000,4801]],"sessionsHisto":[[1386003600000,3]]}},{"map":{"src":{},"dst":{},"xffGeo":{}},"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"count":1,"sessionsHisto":1,"graph":{"source.bytesHisto":[[1335956400000,196]],"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"client.bytesHisto":[[1335956400000,128]],"xmin":1335956400000,"destination.packetsHisto":[[1335956400000,0]],"source.packetsHisto":[[1335956400000,2]],"destination.bytesHisto":[[1335956400000,0]],"server.bytesHisto":[[1335956400000,0]],"interval":3600,"sessionsHisto":[[1335956400000,1]]},"totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0,"name":"byip2"},{"name":"domainwise","totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"count":3,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"map":{"dst":{"US":3},"src":{"US":3},"xffGeo":{}},"graph":{"interval":3600,"sessionsHisto":[[1386003600000,3]],"server.bytesHisto":[[1386003600000,4801]],"destination.bytesHisto":[[1386003600000,6145]],"source.bytesHisto":[[1386003600000,2238]],"client.bytesHisto":[[1386003600000,486]],"xmax":1482552000000,"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"destination.packetsHisto":[[1386003600000,20]],"source.packetsHisto":[[1386003600000,26]]},"sessionsHisto":3},{"graph":{"server.bytesHisto":[[1387742400000,0]],"interval":3600,"sessionsHisto":[[1387742400000,1]],"source.bytesHisto":[[1387742400000,248]],"destination.packetsHisto":[[1387742400000,1]],"xmax":1482552000000,"xmin":1335956400000,"sessionsTotal":1,"network.bytesTotal":314,"totDataBytesTotal":68,"network.packetsTotal":4,"client.bytesHisto":[[1387742400000,68]],"source.packetsHisto":[[1387742400000,3]],"destination.bytesHisto":[[1387742400000,66]]},"sessionsHisto":1,"network.packetsHisto":4,"source.packetsHisto":3,"destination.packetsHisto":1,"count":1,"network.bytesHisto":314,"source.bytesHisto":248,"destination.bytesHisto":66,"map":{"dst":{"CA":1},"src":{"RU":1},"xffGeo":{}},"totDataBytesHisto":68,"client.bytesHisto":68,"server.bytesHisto":0,"name":"dstip"},{"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"name":"hosttaggertest1","map":{"dst":{"US":3},"src":{"US":3},"xffGeo":{}},"count":3,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"sessionsHisto":3,"graph":{"destination.bytesHisto":[[1386003600000,6145]],"source.bytesHisto":[[1386003600000,2238]],"source.packetsHisto":[[1386003600000,26]],"xmax":1482552000000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"destination.packetsHisto":[[1386003600000,20]],"xmin":1335956400000,"client.bytesHisto":[[1386003600000,486]],"interval":3600,"server.bytesHisto":[[1386003600000,4801]],"sessionsHisto":[[1386003600000,3]]}},{"graph":{"sessionsHisto":[[1386003600000,3]],"interval":3600,"server.bytesHisto":[[1386003600000,4801]],"source.bytesHisto":[[1386003600000,2238]],"xmin":1335956400000,"xmax":1482552000000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"client.bytesHisto":[[1386003600000,486]],"destination.packetsHisto":[[1386003600000,20]],"source.packetsHisto":[[1386003600000,26]],"destination.bytesHisto":[[1386003600000,6145]]},"sessionsHisto":3,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"count":3,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"map":{"xffGeo":{},"dst":{"US":3},"src":{"US":3}},"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"name":"hosttaggertest2"},{"name":"iptaggertest1","totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0,"map":{"src":{},"dst":{},"xffGeo":{}},"network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"count":1,"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"sessionsHisto":1,"graph":{"source.bytesHisto":[[1335956400000,196]],"xmin":1335956400000,"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"destination.packetsHisto":[[1335956400000,0]],"client.bytesHisto":[[1335956400000,128]],"source.packetsHisto":[[1335956400000,2]],"destination.bytesHisto":[[1335956400000,0]],"server.bytesHisto":[[1335956400000,0]],"interval":3600,"sessionsHisto":[[1335956400000,1]]}},{"count":1,"network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"map":{"xffGeo":{},"src":{},"dst":{}},"graph":{"source.bytesHisto":[[1335956400000,196]],"source.packetsHisto":[[1335956400000,2]],"client.bytesHisto":[[1335956400000,128]],"xmax":1482552000000,"xmin":1335956400000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"destination.packetsHisto":[[1335956400000,0]],"destination.bytesHisto":[[1335956400000,0]],"server.bytesHisto":[[1335956400000,0]],"interval":3600,"sessionsHisto":[[1335956400000,1]]},"sessionsHisto":1,"name":"iptaggertest2","totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0},{"totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0,"name":"ipwise","network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"count":1,"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"map":{"xffGeo":{},"src":{},"dst":{}},"graph":{"source.bytesHisto":[[1335956400000,196]],"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"destination.packetsHisto":[[1335956400000,0]],"xmin":1335956400000,"client.bytesHisto":[[1335956400000,128]],"source.packetsHisto":[[1335956400000,2]],"destination.bytesHisto":[[1335956400000,0]],"server.bytesHisto":[[1335956400000,0]],"interval":3600,"sessionsHisto":[[1335956400000,1]]},"sessionsHisto":1},{"totDataBytesHisto":68,"client.bytesHisto":68,"server.bytesHisto":0,"name":"ipwisecsv","graph":{"destination.bytesHisto":[[1387742400000,66]],"source.packetsHisto":[[1387742400000,3]],"xmin":1335956400000,"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":314,"totDataBytesTotal":68,"network.packetsTotal":4,"destination.packetsHisto":[[1387742400000,1]],"client.bytesHisto":[[1387742400000,68]],"source.bytesHisto":[[1387742400000,248]],"server.bytesHisto":[[1387742400000,0]],"interval":3600,"sessionsHisto":[[1387742400000,1]]},"sessionsHisto":1,"network.packetsHisto":4,"source.packetsHisto":3,"destination.packetsHisto":1,"count":1,"network.bytesHisto":314,"source.bytesHisto":248,"destination.bytesHisto":66,"map":{"xffGeo":{},"src":{"RU":1},"dst":{"CA":1}}},{"sessionsHisto":1,"graph":{"server.bytesHisto":[[1387742400000,0]],"interval":3600,"sessionsHisto":[[1387742400000,1]],"xmin":1335956400000,"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":314,"totDataBytesTotal":68,"network.packetsTotal":4,"destination.packetsHisto":[[1387742400000,1]],"client.bytesHisto":[[1387742400000,68]],"source.packetsHisto":[[1387742400000,3]],"source.bytesHisto":[[1387742400000,248]],"destination.bytesHisto":[[1387742400000,66]]},"map":{"xffGeo":{},"dst":{"CA":1},"src":{"RU":1}},"count":1,"network.packetsHisto":4,"source.packetsHisto":3,"destination.packetsHisto":1,"network.bytesHisto":314,"source.bytesHisto":248,"destination.bytesHisto":66,"totDataBytesHisto":68,"client.bytesHisto":68,"server.bytesHisto":0,"name":"srcip"},{"map":{"xffGeo":{},"src":{"US":3},"dst":{"US":3}},"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"count":3,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"sessionsHisto":3,"graph":{"destination.bytesHisto":[[1386003600000,6145]],"source.packetsHisto":[[1386003600000,26]],"xmax":1482552000000,"destination.packetsHisto":[[1386003600000,20]],"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"client.bytesHisto":[[1386003600000,486]],"source.bytesHisto":[[1386003600000,2238]],"sessionsHisto":[[1386003600000,3]],"interval":3600,"server.bytesHisto":[[1386003600000,4801]]},"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"name":"wisebyhost2"},{"sessionsHisto":1,"graph":{"interval":3600,"sessionsHisto":[[1335956400000,1]],"server.bytesHisto":[[1335956400000,0]],"source.bytesHisto":[[1335956400000,196]],"xmax":1482552000000,"client.bytesHisto":[[1335956400000,128]],"xmin":1335956400000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"destination.packetsHisto":[[1335956400000,0]],"source.packetsHisto":[[1335956400000,2]],"destination.bytesHisto":[[1335956400000,0]]},"map":{"src":{},"dst":{},"xffGeo":{}},"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"count":1,"network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"name":"wisebyip2","totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0}]'), "items field: tags", { context => 3 });

#source.ip
    $json = get("/spigraph.json?map=true&date=-1&field=source.ip&expression=" . uri_escape("file=$pwd/bigendian.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    eq_or_diff($json->{map}, from_json('{"dst":{"US": 3, "CA": 1}, "src":{"US": 3, "RU":1}, "xffGeo":{}}'), "map field: source.ip");
    eq_or_diff($json->{graph}->{sessionsHisto}, from_json('[["1335956400000", 1], ["1386003600000", 3], [1387742400000, 1], [1482552000000, 1]]'), "sessionsHisto field: source.ip");
    eq_or_diff($json->{graph}->{"source.packetsHisto"}, from_json('[["1335956400000", 2], ["1386003600000", 26], [1387742400000, 3], [1482552000000, 3]]'), "source.packetsHisto field: source.ip");
    eq_or_diff($json->{graph}->{"destination.packetsHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 20], [1387742400000, 1], [1482552000000, 1]]'), "destination.packetsHisto field: source.ip");
    eq_or_diff($json->{graph}->{"client.bytesHisto"}, from_json('[["1335956400000", 128], ["1386003600000", 486], [1387742400000, 68], [1482552000000, 68]]'), "client.bytesHisto field: source.ip");
    eq_or_diff($json->{graph}->{"server.bytesHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 4801], [1387742400000, 0], [1482552000000, 0]]'), "server.bytesHisto field: source.ip");
    my @items = sort({$a->{name} cmp $b->{name}} @{$json->{items}});
    eq_or_diff(\@items, from_json('[{"graph":{"destination.bytesHisto":[[1387742400000,66]],"xmin":1335956400000,"server.bytesHisto":[[1387742400000,0]],"interval":3600,"client.bytesHisto":[[1387742400000,68]],"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":314,"totDataBytesTotal":68,"network.packetsTotal":4,"destination.packetsHisto":[[1387742400000,1]],"sessionsHisto":[[1387742400000,1]],"source.packetsHisto":[[1387742400000,3]],"source.bytesHisto":[[1387742400000,248]]},"totDataBytesHisto":68,"client.bytesHisto":68,"server.bytesHisto":0,"name":"10.0.0.1","network.packetsHisto":4,"source.packetsHisto":3,"destination.packetsHisto":1,"network.bytesHisto":314,"source.bytesHisto":248,"destination.bytesHisto":66,"count":1,"map":{"dst":{"CA":1},"xffGeo":{},"src":{"RU":1}},"sessionsHisto":1},{"graph":{"source.bytesHisto":[[1482552000000,286]],"sessionsHisto":[[1482552000000,1]],"source.packetsHisto":[[1482552000000,3]],"destination.packetsHisto":[[1482552000000,1]],"xmax":1482552000000,"client.bytesHisto":[[1482552000000,68]],"interval":3600,"xmin":1335956400000,"sessionsTotal":1,"network.bytesTotal":368,"totDataBytesTotal":68,"network.packetsTotal":4,"server.bytesHisto":[[1482552000000,0]],"destination.bytesHisto":[[1482552000000,82]]},"count":1,"network.bytesHisto":368,"source.bytesHisto":286,"destination.bytesHisto":82,"network.packetsHisto":4,"source.packetsHisto":3,"destination.packetsHisto":1,"totDataBytesHisto":68,"client.bytesHisto":68,"server.bytesHisto":0,"name":"10.10.10.10","sessionsHisto":1,"map":{"xffGeo":{},"src":{},"dst":{}}},{"sessionsHisto":3,"map":{"dst":{"US":3},"src":{"US":3},"xffGeo":{}},"graph":{"interval":3600,"server.bytesHisto":[[1386003600000,4801]],"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"destination.bytesHisto":[[1386003600000,6145]],"xmax":1482552000000,"destination.packetsHisto":[[1386003600000,20]],"source.packetsHisto":[[1386003600000,26]],"sessionsHisto":[[1386003600000,3]],"source.bytesHisto":[[1386003600000,2238]],"client.bytesHisto":[[1386003600000,486]]},"count":3,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"name":"10.180.156.185"},{"graph":{"interval":3600,"destination.bytesHisto":[[1335956400000,0]],"xmin":1335956400000,"server.bytesHisto":[[1335956400000,0]],"source.packetsHisto":[[1335956400000,2]],"source.bytesHisto":[[1335956400000,196]],"sessionsHisto":[[1335956400000,1]],"destination.packetsHisto":[[1335956400000,0]],"xmax":1482552000000,"sessionsTotal":1,"network.bytesTotal":196,"totDataBytesTotal":128,"network.packetsTotal":2,"client.bytesHisto":[[1335956400000,128]]},"count":1,"name":"192.168.177.160","totDataBytesHisto":128,"client.bytesHisto":128,"server.bytesHisto":0,"network.packetsHisto":2,"source.packetsHisto":2,"destination.packetsHisto":0,"network.bytesHisto":196,"source.bytesHisto":196,"destination.bytesHisto":0,"sessionsHisto":1,"map":{"src":{},"xffGeo":{},"dst":{}}}]'), "items field: source.ip", { context => 3 });
    cmp_ok ($json->{recordsTotal}, '>=', 194);
    cmp_ok ($json->{recordsFiltered}, '==', 6);

#http.requestHeader
    # $json = get("/spigraph.json?map=true&date=-1&field=http.requestHeader&expression=" . uri_escape("file=$pwd/bigendian.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    $json = post("/api/spigraph", '{"map":true, "date":-1, "field":"http.requestHeader", "expression":"file=' . $pwd . '/bigendian.pcap|file=' . $pwd . '/socks-http-example.pcap|file=' . $pwd . '/bt-tcp.pcap"}');
    eq_or_diff($json->{map}, from_json('{"dst":{"US": 3, "CA": 1}, "src":{"US": 3, "RU":1}, "xffGeo":{}}'), "map field: http.requestHeader");
    eq_or_diff($json->{graph}->{sessionsHisto}, from_json('[["1335956400000", 1], ["1386003600000", 3], [1387742400000, 1], [1482552000000, 1]]'), "sessionsHisto field: h1");
    eq_or_diff($json->{graph}->{"source.packetsHisto"}, from_json('[["1335956400000", 2], ["1386003600000", 26], [1387742400000, 3], [1482552000000, 3]]'), "source.packetsHisto field: h1");
    eq_or_diff($json->{graph}->{"destination.packetsHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 20], [1387742400000, 1], [1482552000000, 1]]'), "destination.packetsHisto field: h1");
    eq_or_diff($json->{graph}->{"client.bytesHisto"}, from_json('[["1335956400000", 128], ["1386003600000", 486], [1387742400000, 68], [1482552000000, 68]]'), "client.bytesHisto field: h1");
    eq_or_diff($json->{graph}->{"server.bytesHisto"}, from_json('[["1335956400000", 0], ["1386003600000", 4801], [1387742400000, 0], [1482552000000, 0]]'), "server.bytesHisto field: h1");
    my @items = sort({$a->{name} cmp $b->{name}} @{$json->{items}});
    eq_or_diff(\@items, from_json('[{"graph":{"destination.bytesHisto":[[1386003600000,6145]],"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"server.bytesHisto":[[1386003600000,4801]],"interval":3600,"client.bytesHisto":[[1386003600000,486]],"xmax":1482552000000,"destination.packetsHisto":[[1386003600000,20]],"sessionsHisto":[[1386003600000,3]],"source.packetsHisto":[[1386003600000,26]],"source.bytesHisto":[[1386003600000,2238]]},"name":"accept","totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"count":3,"map":{"dst":{"US":3},"src":{"US":3},"xffGeo":{}},"sessionsHisto":3},{"sessionsHisto":3,"map":{"dst":{"US":3},"src":{"US":3},"xffGeo":{}},"graph":{"destination.bytesHisto":[[1386003600000,6145]],"server.bytesHisto":[[1386003600000,4801]],"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"interval":3600,"client.bytesHisto":[[1386003600000,486]],"source.bytesHisto":[[1386003600000,2238]],"sessionsHisto":[[1386003600000,3]],"source.packetsHisto":[[1386003600000,26]],"destination.packetsHisto":[[1386003600000,20]],"xmax":1482552000000},"count":3,"name":"host","totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20},{"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"name":"user-agent","totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"count":3,"graph":{"client.bytesHisto":[[1386003600000,486]],"xmax":1482552000000,"destination.packetsHisto":[[1386003600000,20]],"sessionsHisto":[[1386003600000,3]],"source.packetsHisto":[[1386003600000,26]],"source.bytesHisto":[[1386003600000,2238]],"xmin":1335956400000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"server.bytesHisto":[[1386003600000,4801]],"destination.bytesHisto":[[1386003600000,6145]],"interval":3600},"map":{"src":{"US":3},"xffGeo":{},"dst":{"US":3}},"sessionsHisto":3}]'), "items field: http.requestHeader", { context => 3 });
cmp_ok ($json->{recordsTotal}, '>=', 194);
cmp_ok ($json->{recordsFiltered}, '==', 6);

#http.useragent
    $json = get("/spigraph.json?map=true&date=-1&field=http.useragent&expression=" . uri_escape("file=$pwd/socks5-reverse.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    my @items = sort({$a->{name} cmp $b->{name}} @{$json->{items}});
    eq_or_diff(\@items, from_json('[{"network.bytesHisto":27311,"source.bytesHisto":25112,"destination.bytesHisto":2199,"totDataBytesHisto":24346,"client.bytesHisto":23392,"server.bytesHisto":954,"network.packetsHisto":52,"source.packetsHisto":31,"destination.packetsHisto":21,"count":1,"graph":{"client.bytesHisto":[[1386788400000,23392]],"source.bytesHisto":[[1386788400000,25112]],"source.packetsHisto":[[1386788400000,31]],"interval":3600,"sessionsHisto":[[1386788400000,1]],"xmin":1386003600000,"sessionsTotal":1,"network.bytesTotal":27311,"totDataBytesTotal":24346,"network.packetsTotal":52,"server.bytesHisto":[[1386788400000,954]],"destination.packetsHisto":[[1386788400000,21]],"xmax":1482552000000,"destination.bytesHisto":[[1386788400000,2199]]},"map":{"dst":{"CA":1},"src":{"RU":1},"xffGeo":{}},"name":"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)","sessionsHisto":1},{"network.bytesHisto":8383,"source.bytesHisto":2238,"destination.bytesHisto":6145,"totDataBytesHisto":5287,"client.bytesHisto":486,"server.bytesHisto":4801,"network.packetsHisto":46,"source.packetsHisto":26,"destination.packetsHisto":20,"count":3,"graph":{"destination.bytesHisto":[[1386003600000,6145]],"xmin":1386003600000,"sessionsTotal":3,"network.bytesTotal":8383,"totDataBytesTotal":5287,"network.packetsTotal":46,"server.bytesHisto":[[1386003600000,4801]],"xmax":1482552000000,"destination.packetsHisto":[[1386003600000,20]],"sessionsHisto":[[1386003600000,3]],"interval":3600,"client.bytesHisto":[[1386003600000,486]],"source.bytesHisto":[[1386003600000,2238]],"source.packetsHisto":[[1386003600000,26]]},"map":{"src":{"US":3},"xffGeo":{},"dst":{"US":3}},"sessionsHisto":3,"name":"curl/7.24.0 (x86_64-apple-darwin12.0) libcurl/7.24.0 OpenSSL/0.9.8y zlib/1.2.5"}]'), "items field: http.useragent", { context => 3 });
    eq_or_diff($json->{graph}->{sessionsHisto}, from_json('[["1386003600000", 3], ["1386788400000", 1], [1387742400000, 1], [1482552000000, 1]]'), "multi sessionsHisto field: http.useragent");
    eq_or_diff($json->{graph}->{"source.packetsHisto"}, from_json('[["1386003600000", 26], ["1386788400000", 31], [1387742400000, 3], [1482552000000, 3]]'), "multi source.packetsHisto field: http.useragent");
    eq_or_diff($json->{graph}->{"destination.packetsHisto"}, from_json('[["1386003600000", 20], ["1386788400000", 21], [1387742400000, 1], [1482552000000, 1]]'), "multi destination.packetsHisto field: http.useragent");
    eq_or_diff($json->{graph}->{"client.bytesHisto"}, from_json('[["1386003600000", 486], ["1386788400000", 23392], [1387742400000, 68], [1482552000000, 68]]'), "multi client.bytesHisto field: http.useragent");
    eq_or_diff($json->{graph}->{"server.bytesHisto"}, from_json('[["1386003600000", 4801], ["1386788400000", 954], [1387742400000, 0], [1482552000000, 0]]'), "multi server.bytesHisto field: http.useragent");
    cmp_ok ($json->{recordsTotal}, '>=', 194);
    cmp_ok ($json->{recordsFiltered}, '==', 6);

# no map data
    $json = get("/spigraph.json?date=-1&field=http.useragent&expression=" . uri_escape("file=$pwd/socks5-reverse.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    eq_or_diff($json->{map}, from_json('{}'), "no map data");

# file field works
    $json = post("/spigraph.json?date=-1&field=fileand&expression=" . uri_escape("file=$pwd/bigendian.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    cmp_ok ($json->{recordsFiltered}, '==', 6);

# ip.dst:port works
    $json = get("/spigraph.json?date=-1&field=ip.dst:port&expression=" . uri_escape("file=$pwd/socks5-reverse.pcap|file=$pwd/socks-http-example.pcap|file=$pwd/bt-tcp.pcap"));
    cmp_ok ($json->{recordsTotal}, '>=', 318);
    cmp_ok ($json->{recordsFiltered}, '==', 6);
