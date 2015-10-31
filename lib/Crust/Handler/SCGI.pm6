use v6;

use SCGI;

unit class Crust::Handler::SCGI;

has $!scgi;

submethod BUILD(:$host, :$port) {
    $!scgi = SCGI.new(:addr($host), :port($port));
}

method run($app) {
    $scgi.handle: $app;
}
