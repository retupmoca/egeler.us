use HTMLPage;
use SiteDB;
use Page::Redirect;

class Section::Blog::AddPost does HTMLPage;

method html-template { 'add-blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        SiteDB.with-database: 'blog', -> $dbh {
            $dbh.do('INSERT INTO posts SET posted=NOW()'
                                        ~',title=?'
                                        ~',body=?'
                                        ~',author=?'
                                        ~',tags=?',
                         $request.params<title>,
                         $request.params<body>,
                         $session.data<local-login>,
                         $request.params<tags>);
        };

        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}
