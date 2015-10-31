use Section::Blog::Data::Post;
use Page::Redirect;
use Site::Template;

unit class Section::Blog::EditPost;

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        my $params = $request.parameters;
        $request.uri ~~ /\/(\d+)\//;
        my $id = $0;
        my $p = Section::Blog::Data::Post.load(:$id);

        die "Not authorized" unless $p.author eq $session.data<local-login>;

        $p.title = $params<title>;
        $p.body = $params<body>;
        my @tags = $params<tags>.split(/\,/);
        @tags.map(-> $_ is rw { $_ ~~ s/^\s+//; $_ ~~ s/\s+$//; });
        @tags = @tags.grep({$_});
        $p.tags = @tags;

        $p.save;

        return Page::Redirect.new(:code(302), :url('/blog'))
                             .handle(:$request, :$session);
    }
    my %data;

    %data<edit> = 1;
    $request.uri ~~ /\/(\d+)\//;
    my $id = $0;
    my $p = Section::Blog::Data::Post.load(:$id);

    %data<id> = $p.id;
    %data<title> = $p.title;
    %data<body> = $p.body;
    %data<tags> = $p.tags.join(',');

    die "Not authorized" unless $p.author eq $session.data<local-login>;

    return [200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('add-blog-post.tmpl')).render(%data) ]];
}
