use HTMLPage;
use SiteDB;
use Page::Redirect;

unit class Section::Blog::EditPost does HTMLPage;

method html-template { 'add-blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.method eq 'POST' {
        $request.uri ~~ /\/(\d+)\//;
        my $id = $0;
        SiteDB.with-database: 'blog', -> $dbh {

            my $p = $dbh.with-query: 'SELECT * FROM posts WHERE id=?', $id,
                                       *.fetchrow-hash;

            die "Not authorized" unless $p<author> eq $session.data<local-login>;

            $dbh.do('UPDATE posts SET '
                                    ~'title=?'
                                    ~',body=?'
                                    ~',tags=?'
                                    ~' WHERE id=?',
                         $request.params<title>,
                         $request.params<body>,
                         $request.params<tags>,
                         $id);
        };

        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}

method data {
    my %data;

    %data<edit> = 1;
    $.request.uri ~~ /\/(\d+)\//;
    my $id = $0;

    SiteDB.with-database: 'blog', -> $dbh {
        my $p = $dbh.with-query: 'SELECT * FROM posts WHERE id=?', $id,
                                   *.fetchrow-hash;

        given $p {
            %data<id> = $_<id>;
            %data<title> = $_<title>;
            %data<body> = $_<body>;
            %data<tags> = $_<tags>;
        }

        die "Not authorized" unless $p<author> eq $.session.data<local-login>;
    };

    return %data;
}
