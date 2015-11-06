use Web::RF;

unit class Page::Redirect is Web::RF::Controller;

has $.code;
has $.url;

method handle() { [ $.code, [ 'Location' => $.url ], []] }
method go(:$code, :$url) { self.new(:$code, :$url).handle(); };
