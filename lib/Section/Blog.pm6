use Site::Tools;

unit class Section::Blog is Site::Router;

use Section::Blog::Home;
use Section::Blog::AddPost;
use Section::Blog::EditPost;
use Section::Blog::DeletePost;
use Section::Blog::Post;

method routes {
    $.route('',             Section::Blog::Home);
    $.route('u/:user',      Section::Blog::Home);
    $.route('add-post',     Section::Blog::AddPost);
    $.route('p/:id/edit',   Section::Blog::EditPost);
    $.route('p/:id/delete', Section::Blog::DeletePost);
    $.route('p/:id',        Section::Blog::Post);
}
