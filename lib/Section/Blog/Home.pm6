use HTMLPage;
use SiteDB;
use Text::Markdown;
use Text::Markdown::to::HTML;
use Syndication;

unit class Section::Blog::Home does HTMLPage;

has $!feed;

method html-type {
    return 'text/xml; charset=utf-8' if $.request.params<rss>;
}

method html-data {
    ~$!feed;
}

method html-template {
    return False if $.request.params<rss>;
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
    my @rss-items;
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
            my $md = Text::Markdown::Document.new($p<body>);
            $p<body> = $md.render(Text::Markdown::to::HTML);
            if $.session.data<local-login> && $p<author> eq $.session.data<local-login> {
                $p<own-post> = 1;
            }
            if $.request.params<rss> {
                @rss-items.push: Syndication::RSS::Item.new(:title($p<title>),
                                                            :link('https://egeler.us/blog/p/'~$p<id>),
                                                            :summary($p<body>),
                                                            :author($p<author>),
                                                            :updated(DateTime.new($p<posted>.subst(/\s/, 'T') ~ 'Z')));
            }
        }
        if $.request.params<rss> {
            $!feed = Syndication::RSS.new(:title('Egeler Blog'), :link($.request.uri), :description(''), :items(@rss-items));
        }
        %param<posts> = @posts;
        %param<login> = $.session.data<local-login>;

        %param<page> = $page;
        %param<next-page> = '?page=' ~ ($page + 1) if @posts == $perpage;
        %param<prev-page> = '?page=' ~ ($page - 1) if $page > 0;
    };

    return %param;
}
