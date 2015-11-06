use Web::RF;
use Site::Tools;
use Section::Blog::Data::Post;
use Page::Redirect;
use Site::Template;

unit class Section::Blog::AddPost is Web::RF::Controller::Authed;

multi method handle(Get :$request) {
    return [200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('add-blog-post.tmpl')).render() ]];
}
multi method handle(Post :$request) {
    my $params = $request.parameters;
    my @tags = $params<tags>.split(/\,/);
    @tags.map(-> $_ is rw { $_ ~~ s/^\s+//; $_ ~~ s/\s+$//; });
    @tags = @tags.grep({$_});
    my $p = Section::Blog::Data::Post.new(:title($params<title>),
                                          :body($params<body>),
                                          :author($request.session.data<local-login>),
                                          :tags(@tags));

    $p.save;

    return Page::Redirect.go(:code(302), :url('/blog'));
}
