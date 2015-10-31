use Section::Blog::Data::Post;
use Page::Redirect;
use Site::Template;

unit class Section::Blog::AddPost;

method handle(:$request, :$session) {
    if $request.method eq 'POST' {
        my @tags = $request.params<tags>.split(/\,/);
        @tags.map(-> $_ is rw { $_ ~~ s/^\s+//; $_ ~~ s/\s+$//; });
        @tags = @tags.grep({$_});
        my $p = Section::Blog::Data::Post.new(:title($request.params<title>),
                                              :body($request.params<body>),
                                              :author($session.data<local-login>),
                                              :tags(@tags));

        $p.save;

        return Page::Redirect.new(:code(302), :url('/blog'))
                             .handle(:$request, :$session);
    }
    return [200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('add-blog-post.tmpl')).render() ]];
}
