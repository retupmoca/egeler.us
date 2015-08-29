use SiteDB;

unit class Section::Blog::Data::Post;

has $.id;
has $.title is rw;
has $.body is rw;
has @.tags is rw;
has $.author;
has $.posted;

method load(:$id) {
    SiteDB.with-database: 'blog', -> $dbh {
        $dbh.with-query: 'SELECT * FROM posts WHERE id=?', $id, -> $sth {
            my $p = $sth.fetchrow-hash;
            self.bless(:id($p<id>),
                       :title($p<title>),
                       :body($p<body>),
                       :tags($p<tags>.split(/\,/)),
                       :author($p<author>),
                       :posted(DateTime.new($p<posted>.subst(/\s/, 'T')~'Z')));
        }
    }
}

method search(:$author, :$tag, :$count!, :$offset!) {
    my @query = 'SELECT * FROM posts';

    if $author {
        @query[0] ~= ' WHERE author=?';
        @query.push: $author;
    }
    if $tag {
        die "NYI";
    }

    @query[0] ~= ' ORDER BY posted DESC LIMIT '~$offset~','~$count;

    my @ret;
    SiteDB.with-database: 'blog', -> $dbh {
        $dbh.with-query: |@query, -> $sth {
            while $sth.fetchrow-hash -> $p {
                @ret.push:
                    self.bless(:id($p<id>),
                               :title($p<title>),
                               :body($p<body>),
                               :tags($p<tags>.split(/\,/)),
                               :author($p<author>),
                               :posted(DateTime.new($p<posted>.subst(/\s/, 'T')~'Z')));
            }
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
                                    ~',tags=?'
                                    ~' WHERE id=?',
                         $.title,
                         $.body,
                         @.tags.join(','),
                         $.id);
        }
        else {
            $dbh.do('INSERT INTO posts SET posted=NOW()'
                                        ~',title=?'
                                        ~',body=?'
                                        ~',author=?'
                                        ~',tags=?',
                         $.title,
                         $.body,
                         $.author,
                         @.tags.join(','));
            $!id = $dbh.mysql_insertid;
            $!posted = DateTime.now;
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
