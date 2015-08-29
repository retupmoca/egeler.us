use HTMLPage;
use Section::Blog::Data::Post;
use Text::Markdown;
use Text::Markdown::to::HTML;
use Page::Redirect;

unit class Section::Blog::Post does HTMLPage;

method html-template { 'blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.uri ~~ /\/(\d+)\/delete$/ {
        my $id = $0;
        my $p = Section::Blog::Data::Post.load(:$id);

        die "Not authorized" unless $p.author eq $session.data<local-login>;

        $p.delete;
        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}

method data {
    $.request.uri ~~ /\/(\d+)/;
    my $id = $0;
    my $p = Section::Blog::Data::Post.load(:$id);
    my %d;

    my $md = Text::Markdown::Document.new($p.body);
    %d<body> = $md.render(Text::Markdown::to::HTML);
    if $.session.data<local-login> && $p.author eq $.session.data<local-login> {
        %d<own-post> = 1;
    }

    %d<id> = $p.id;
    %d<title> = $p.title;
    %d<tags> = $p.tags.join(',');
    %d<author> = $p.author;
    %d<posted> = $p.posted.Str.subst(/Z$/, '').subst(/T/, ' ');

    return %d;
}
