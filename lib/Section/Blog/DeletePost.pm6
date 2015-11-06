use Web::RF;
use Site::Tools;
use Section::Blog::Data::Post;
use Page::Redirect;

unit class Section::Blog::DeletePost is Web::RF::Controller::Authed;

multi method handle(:$request, :%mapping) {
    my $id = %mapping<id>;
    my $p = Section::Blog::Data::Post.load(:$id);

    die "Not authorized" unless $p.author eq $request.session.data<local-login>;

    $p.delete;
    return Page::Redirect.go(:code(302), :url('/blog'));
}
