use Web::RF;
use Section::Blog::Data::Post;
use Site::Template;

unit class Section::Blog::Post is Web::RF::Controller;

multi method handle(Get :$request, :%mapping) {
    my $id = %mapping<id>;
    my $p = Section::Blog::Data::Post.load(:$id);
    my %d;

    if $request.user-id && $p.author eq $request.user-id {
        %d<own-post> = 1;
    }

    %d<body> = $p.html-body;
    %d<id> = $p.id;
    %d<title> = $p.title;
    %d<tags> = $p.tags.join(',');
    %d<author> = $p.author;
    %d<posted> = $p.posted.Str.subst(/Z$/, '').subst(/T/, ' ');

    return [200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('blog-post.tmpl')).render(%d) ]];
}
