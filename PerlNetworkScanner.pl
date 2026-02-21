#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Engine::NetworkService;


# Variables to store options
my $ip = '';
my $port = 0;
my $polite = 1;
my $help;

# Define options
GetOptions(
    'ip=s' => \$ip,
    'port=i'  => \$port,  
    'help'   => \$help
) or die "Error in command line arguments\n";

# Print help message
if ($help) {
    print "Usage: $0 --ip <ip address> --port <port>\n";
    exit;
}

print check_single_port($ip, $port);