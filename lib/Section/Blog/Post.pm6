use Site::Tools;
use Section::Blog::Data::Post;
use Site::Template;

unit class Section::Blog::Post is Site::Controller;

multi method handle(Get :$request, :%mapping) {
    my $id = %mapping<id>;
    my $session = $request.session;
    my $p = Section::Blog::Data::Post.load(:$id);
    my %d;

    if $session.data<local-login> && $p.author eq $session.data<local-login> {
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
