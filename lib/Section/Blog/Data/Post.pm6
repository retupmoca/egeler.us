use SiteDB;
use Text::Markdown;
use Text::Markdown::to::HTML;

unit class Section::Blog::Data::Post;

has $.id;
has $.title is rw;
has $.body is rw;
has @.tags is rw;
has $.author;
has $.posted;

method html-body {
    my $md = Text::Markdown::Document.new($.body);
    $md.render(Text::Markdown::to::HTML);
}

method load(:$id) {
    SiteDB.with-database: 'blog', -> $dbh {
        my $p = $dbh.with-query: 'SELECT * FROM posts WHERE id=?', $id, *.fetchrow-hash;
        $dbh.with-query: 'SELECT * FROM post_tags WHERE post_id=?', $p<id>, -> $sth {
            while $sth.fetchrow-hash -> $t { @tags.push($t<tag>) }
        };
        self.bless(:id($p<id>),
                   :title($p<title>),
                   :body($p<body>),
                   :tags(@tags),
                   :author($p<author>),
                   :posted(DateTime.new($p<posted>.subst(/\s/, 'T')~'Z')));
    }
}

method search(:$author, :$tag, :$count!, :$offset!) {
    my @query = 'SELECT * FROM posts WHERE 1=1';

    if $author {
        @query[0] ~= ' AND author=?';
        @query.push: $author;
    }
    if $tag {
        @query[0] ~= ' AND (SELECT COUNT(*) FROM post_tags WHERE post_id=id AND tag=?)>0';
        @query.push: $tag;
    }

    @query[0] ~= ' ORDER BY posted DESC LIMIT '~$offset~','~$count;

    my @ret;
    SiteDB.with-database: 'blog', -> $dbh {
        my @posts;
        $dbh.with-query: |@query, -> $sth {
            while $sth.fetchrow-hash -> $p { @posts.push($p) }
        };
        for @posts -> $p {
            my @tags;
            $dbh.with-query: 'SELECT * FROM post_tags WHERE post_id=?', $p<id>, -> $sth {
                while $sth.fetchrow-hash -> $t { @tags.push($t<tag>) }
            };
            @ret.push:
                self.bless(:id($p<id>),
                           :title($p<title>),
                           :body($p<body>),
                           :tags(@tags),
                           :author($p<author>),
                           :posted(DateTime.new($p<posted>.subst(/\s/, 'T')~'Z')));
        }
    }

    @ret;
}

method save {
    SiteDB.with-database: 'blog', -> $dbh {
        if $.id {
            $dbh.do('UPDATE posts SET '
                                    ~'title=?'
                                    ~',body=?'
                                    ~' WHERE id=?',
                         $.title,
                         $.body,
                         $.id);
            $dbh.do('DELETE FROM post_tags WHERE id=?', $.id);
            for @.tags -> $tag {
                $dbh.do('INSERT INTO post_tags SET post_id=?,tag=?', $.id, $tag);
            }
        }
        else {
            $dbh.do('INSERT INTO posts SET posted=NOW()'
                                        ~',title=?'
                                        ~',body=?'
                                        ~',author=?',
                         $.title,
                         $.body,
                         $.author);
            $!id = $dbh.mysql_insertid;
            $!posted = DateTime.now;
            for @.tags -> $tag {
                $dbh.do('INSERT INTO post_tags SET post_id=?,tag=?', $.id, $tag);
            }
        }
    }
}

method delete {
    SiteDB.with-database: 'blog', -> $dbh {
        if $.id {
            $dbh.do('DELETE FROM posts WHERE id=?', $.id);
            $!id = Nil;
        }
    }
}
