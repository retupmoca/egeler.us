use HTMLPage;

unit class Page::Redirect does HTMLPage;

has $.code;
has $.url;

method html-status { $!code }
method html-headers {
    my @h;
    @h.push('Location' => $!url);
    return @h;
}
