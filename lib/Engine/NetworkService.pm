package Engine::NetworkService;
use FindBin;
use lib "$FindBin::Bin/local/lib/perl5";
use IO::Socket::INET;
use IO::Select;
use NetAddr::IP;
use strict;
use warnings;
use feature 'signatures';
use feature 'try';
use feature 'try';
no warnings 'experimental::try';
use Exporter 'import';
our @EXPORT  = qw(check_open_ports);

sub check_single_port ($target, $port) {
    my $socket = IO::Socket::INET->new(
        PeerAddr => $target,
        PeerPort => $port,
        Proto    => 'tcp',
        Timeout  => 5
    ) or die "Could not connect to $target on port $port: $!\n";

    print "Connected to $target:$port\n";

    if ($port == 80 || $port == 443) {
        print $socket get_request_string($target);
    }

    # Grab that banner
    my $select = IO::Select->new($socket);

    my $banner = "";

    if ($select->can_read(3)) {
        sysread($socket, $banner, 1024);
            $banner =~ s/[^[:print:]]/ /g;
            $banner =~ s/^\s+|\s+$//g;

    }
    $socket->close();

    return $banner;
}

sub get_request_string ($target) {
    # Emulate being a real browser
    return <<~REQUEST;
        HEAD / HTTP/1.1\r
        Host: $target\r
        User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)\r
        Connection: close\r
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8\r
        Accept-Language: sv-SE,sv;q=0.9,en-US;q=0.8,en;q=0.7\r\n
        \r
        REQUEST
}

sub check_ip_for_open_ports ($ip, $port_range) {
    my ($min, $max) = split(/:/, $port_range);
    print "Checking $ip, $port_range";
    for my $port ($min...$max // $min) {
        try {
            check_single_port($ip, $port)
        }
        catch ($e) {
            warn "Caught an error: $e";
        }
    }

}

sub check_open_ports ($cidr_range, $port_range) {
    my $ips_to_check = NetAddr::IP->new($cidr_range)->hostenumref;

    foreach my $ip (@$ips_to_check) {
        print "Checking: $ip";
        check_ip_for_open_ports($ip->addr, $port_range)
    }
}