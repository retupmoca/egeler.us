unit class Page::Redirect;

has $.code;
has $.url;

method handle(:$request, :$session) { [ $.code, [ 'Location' => $.url ], []] }
