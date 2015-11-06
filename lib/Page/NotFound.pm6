use Web::RF;
use Site::Template;

unit class Page::NotFound is Web::RF::Controller;

method handle {
    my $tmpl = Site::Template.new(:file('404.html'));
    return [ 404, [ 'Content-Type' => 'text/html' ], [ $tmpl.render() ]];
}
