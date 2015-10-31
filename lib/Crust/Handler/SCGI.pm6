use v6;

use SCGI;

unit class Crust::Handler::SCGI;

has $!scgi;

method new(*%args) {
    my $host = %args<host> || '127.0.0.1';
    my $port = %args<port> || 9010;
    self.bless()!initialize(:$host, :$port);
}

method !initialize(:$host, :$port) {
    $!scgi = SCGI.new(:addr($host), :port($port));
}

method run($app) {
    $scgi.handle: $app;
}
