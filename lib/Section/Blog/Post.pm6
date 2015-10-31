use Section::Blog::Data::Post;
use Page::Redirect;
use Site::Template;

unit class Section::Blog::Post;

method handle(:$request, :$session, :%mapping) {
    if $request.request-uri ~~ /\/(\d+)\/delete$/ {
        my $id = $0;
        my $p = Section::Blog::Data::Post.load(:$id);

        die "Not authorized" unless $p.author eq $session.data<local-login>;

        $p.delete;
        return Page::Redirect.new(:code(302), :url('/blog'))
                             .handle(:$request, :$session);
    }
    my $id = %mapping<id>;
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
