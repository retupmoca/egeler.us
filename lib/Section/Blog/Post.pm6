use HTMLPage;
use SiteDB;
use File::Temp;
use Page::Redirect;

class Section::Blog::Post does HTMLPage;

method html-template { 'blog-post.tmpl' }

method new(:$request, :$session) {
    if $request.uri ~~ /\/(\d+)\/delete$/ {
        my $id = $0;
        SiteDB.with-database: 'blog', -> $dbh {
            my $p = $dbh.with-query: 'SELECT * FROM posts WHERE id=?', $id,
                                       *.fetchrow-hash;

            die "Not authorized" unless $p<author> eq $session.data<local-login>;

            $dbh.do('DELETE FROM posts WHERE id=?', $id);
        };

        return Page::Redirect.new(:code(302), :url('/blog'));
    }
    self.bless(:$request, :$session);
}

method data {
    my %d;
    $.request.uri ~~ /\/(\d+)/;
    my $id = $0;
    my $p = SiteDB.with-database: 'blog', {
        $_.with-query: 'SELECT * FROM posts WHERE id=?', $id,
                         *.fetchrow-hash;
    };

    my ($inf, $infh) = tempfile(:!unlink);
    $infh.spurt: $p<body>;
    my ($of, $ofh) = tempfile(:!unlink);
    shell('markdown_py <'~$inf~' >'~$of);
    $p<body> = $of.IO.slurp;
    unlink($of);
    unlink($inf);
    if $.session.data<local-login> && $p<author> eq $.session.data<local-login> {
        $p<own-post> = 1;
    }

    for $p.kv -> $k, $v {
        %d{$k} = $v;
    }
    return %d;
}
