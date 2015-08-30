use HTMLPage;
use Section::Blog::Data::Post;
use Page::Redirect;

unit class Section::Blog::EditPost does HTMLPage;

method html-template { 'add-blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        $request.uri ~~ /\/(\d+)\//;
        my $id = $0;
        my $p = Section::Blog::Data::Post.load(:$id);

        die "Not authorized" unless $p.author eq $session.data<local-login>;

        $p.title = $request.params<title>;
        $p.body = $request.params<body>;
        my @tags = $request.params<tags>.split(/\,/);
        @tags.map(-> $_ is rw { $_ ~~ s/^\s+//; $_ ~~ s/\s+$//; });
        @tags.grep({$_});
        $p.tags = @tags;

        $p.save;

        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}

method data {
    my %data;

    %data<edit> = 1;
    $.request.uri ~~ /\/(\d+)\//;
    my $id = $0;
    my $p = Section::Blog::Data::Post.load(:$id);

    %data<id> = $p.id;
    %data<title> = $p.title;
    %data<body> = $p.body;
    %data<tags> = $p.tags.join(',');

    die "Not authorized" unless $p.author eq $.session.data<local-login>;

    return %data;
}
