#!/usr/bin/perl

use URI::Escape;

my $encodedurl = $ARGV[0];

my $url = uri_unescape($encodedurl);

print "$url";
