use Site::Tools;

unit class Page::Redirect is Site::Controller;

has $.code;
has $.url;

method handle() { [ $.code, [ 'Location' => $.url ], []] }
method go(:$code, :$url) { self.new(:$code, :$url).handle(); };
