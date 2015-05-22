#!/usr/local/bin/perl6
use v6;

use Site;
use Config;

use SCGI;
use HTTP::Easy::PSGI;

multi MAIN(Bool :$dev!) {
    Config.load("/etc/perlsite.conf");
    my $site = Site.new;

    my $handler = sub (%env) {
        $site.handle(%env);
    };

    my $http = HTTP::Easy::PSGI.new(:port(8080));
    
    $http.handle: $handler;
}

multi MAIN() {
    Config.load("/etc/perlsite.conf");
    my $site = Site.new;

    my $handler = sub (%env) {
        $site.handle(%env);
    };

    my $scgi = SCGI.new(:addr('0.0.0.0'), :port(9010));

    $scgi.handle: $handler;
}
