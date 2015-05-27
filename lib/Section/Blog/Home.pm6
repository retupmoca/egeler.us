use HTMLPage;
use SiteDB;
use Text::Markdown;

class Section::Blog::Home does HTMLPage;

method html-template {
    $.request.uri ~~ /\/u\/(<-[\/]>+)$/;
    my $user = $0;
    if $user && "/home/$user/blog/home.tmpl".IO.e {
        return "/home/$user/blog/home.tmpl";
    }
    else {
        return 'blog.tmpl';
    }
}

method data {
    my %param;
    $.request.uri ~~ /\/u\/(<-[\/]>+)$/;
    my $user = $0;
    SiteDB.with-database: 'blog', -> $dbh {
        my $perpage = 25;
        my $page = $.request.params<page> || 0;

        my $sth;
        if $user {
            $sth = $dbh.prepare('SELECT * FROM posts WHERE author=? ORDER BY posted DESC'
                                ~' LIMIT '~($perpage * $page)~','~($perpage * ($page + 1))
            );
            $sth.execute($user);
        }
        else {
            $sth = $dbh.prepare('SELECT * FROM posts ORDER BY posted DESC'
                                ~' LIMIT '~($perpage * $page)~','~($perpage * ($page + 1))
            );
            $sth.execute;
        }
        my @posts = $sth.fetchall-AoH;
        $sth.finish;
        for @posts -> $p is rw {
            my $md = Text::Markdown.new($p<body>);
            $p<body> = $md.render;
            if $.session.data<local-login> && $p<author> eq $.session.data<local-login> {
                $p<own-post> = 1;
            }
        }
        %param<posts> = @posts;
        %param<login> = $.session.data<local-login>;

        %param<page> = $page;
        %param<next-page> = '?page=' ~ ($page + 1) if @posts == $perpage;
        %param<prev-page> = '?page=' ~ ($page - 1) if $page > 0;
    };

    return %param;
}
