use Web::RF;
use Section::Blog::Data::Post;
use Site::Template;

unit class Section::Blog::AddPost is Web::RF::Controller::Authed;

multi method handle(Get :$request) {
    my %data;
    %data<id> = '';
    %data<title> = '';
    %data<body> = '';
    %data<tags> = '';

    return [200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('add-blog-post.tmpl')).render(%data) ]];
}
multi method handle(Post :$request) {
    my $params = $request.parameters;
    my @tags = $params<tags>.split(/\,/);
    @tags.map(-> $_ is rw { $_ ~~ s/^\s+//; $_ ~~ s/\s+$//; });
    @tags = @tags.grep({$_});
    my $p = Section::Blog::Data::Post.new(:title($params<title>),
                                          :body($params<body>),
                                          :author($request.user-id),
                                          :tags(@tags));

    $p.save;

    my $url = $.url-for('Section::Blog::Post', :id($p.id));
    return Web::RF::Redirect.go(:code(302), :$url);
}
