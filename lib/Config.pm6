unit class Config;

use JSON::Tiny;

my $data;

method load($path) {
    $data = from-json($path.IO.slurp);
}

method get($key) {
    $data{$key};
}
