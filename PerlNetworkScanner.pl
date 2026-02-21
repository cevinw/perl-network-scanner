#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Engine::NetworkService;



my $ip = '';
my $port = '';
my $polite = 1;
my $help;

GetOptions(
    'ip=s' => \$ip,
    'port=s'  => \$port,  
    'help'   => \$help
) or die "Error in command line arguments\n";


if ($help) {
    print "Usage: $0 --ip <ip or ip/n cidr> --port <port or begin_port:end_port>\n";
    exit;
}

print check_open_ports($ip, $port);