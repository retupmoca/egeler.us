use Web::RF;
use Section::Blog::Home;
use Section::Blog::Data::Post;

unit class Section::Blog::DeletePost is Web::RF::Controller::Authed;

multi method handle(:$request, :$id!) {
    my $p = Section::Blog::Data::Post.load(:$id);

    die "Not authorized" unless $p.author eq $request.user-id;

    $p.delete;

    my $url = $.url-for(Section::Blog::Home);
    return Web::RF::Redirect.go(:code(302), :$url);
}
