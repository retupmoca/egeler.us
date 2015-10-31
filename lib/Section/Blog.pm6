use Path::Router;

unit class Section::Blog;

use Section::Blog::Home;
use Section::Blog::AddPost;
use Section::Blog::EditPost;
use Section::Blog::Post;

method router {
    my $router = Path::Router.new;
    $router.add-route('', target => Section::Blog::Home);
    $router.add-route('u/:user', target => Section::Blog::Home);
    $router.add-route('add-post', target => Section::Blog::AddPost);
    $router.add-route('p/:id/edit', target => Section::Blog::EditPost);
    $router.add-route('p/:id', target => Section::Blog::Post);
    return $router;
}
