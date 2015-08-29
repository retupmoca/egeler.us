use HTMLPage;
use Section::Blog::Data::Post;
use Page::Redirect;

unit class Section::Blog::AddPost does HTMLPage;

method html-template { 'add-blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        my $p = Section::Blog::Data::Post.new(:title($request.params<title>),
                                              :body($request.params<body>),
                                              :author($session.data<local-login>),
                                              :tags($request.params<tags>.split(/\,/)));

        $p.save;

        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}
