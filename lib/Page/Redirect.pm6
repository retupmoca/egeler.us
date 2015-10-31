unit class Page::Redirect;

has $.code;
has $.url;

method handle() { [ $.code, [ 'Location' => $.url ], []] }
method go(:$code, :$url) { self.new(:$code, :$url).handle(); };
