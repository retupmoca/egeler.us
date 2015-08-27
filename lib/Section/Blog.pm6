unit class Section::Blog;

use Section::Blog::Home;
use Section::Blog::AddPost;
use Section::Blog::EditPost;
use Section::Blog::Post;

method dispatch($basepath) {
    my @d;
    @d.push([
        -> $r, $s {
            my $uri = $r.uri;
            $uri ~~ s/\?.+$//;
            $uri eq $basepath
            || $uri ~~ /^$basepath\/u\/<-[\/]>+$/;
        }, Section::Blog::Home]);
    @d.push([
        -> $r, $s {
            $r.uri eq $basepath ~ '/add-post'
            && $s.data<local-login>;
        }, Section::Blog::AddPost]);
    @d.push([
        -> $r, $s {
            $r.uri ~~ /^$basepath\/p\/\d+\/edit/;
        }, Section::Blog::EditPost]);
    @d.push([
        -> $r, $s {
            $r.uri ~~ /^$basepath\/p\//;
        }, Section::Blog::Post]);
    return @d;
}
