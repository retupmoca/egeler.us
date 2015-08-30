use HTMLPage;
use Section::Blog::Data::Post;
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
    $user ~~ s/\?.+// if $user;
    my @rss-items;

    my $perpage = 25;
    my $page = $.request.params<page> || 0;

    my @posts = Section::Blog::Data::Post.search(:author($user), 
                                                 :tag($.request.params<tag>),
                                                 :count($perpage),
                                                 :offset($perpage * $page));
    my @tposts;
    for @posts -> $p {
        if $.request.params<rss> {
            @rss-items.push: Syndication::RSS::Item.new(:title($p.title),
                                                        :link('https://egeler.us/blog/p/'~$p.id),
                                                        :summary($p.body),
                                                        :author($p.author),
                                                        :updated($p.posted));
        }
        my %d;

        if $.session.data<local-login>
           && $p.author eq $.session.data<local-login> {
            %d<own-post> = 1;
        }

        %d<body> = $p.html-body;
        %d<id> = $p.id;
        %d<title> = $p.title;
        %d<tags> = $p.tags.join(',');
        %d<tags_list> = $p.tags.map({ ( tag => $_, comma => 1 ).hash.item });
        %d<tags_list>[*-1]<comma> = 0 if $p.tags;
        %d<author> = $p.author;
        %d<posted> = $p.posted.Str.subst(/Z$/, '').subst(/T/, ' ');

        @tposts.push($%d);
    }
    if $.request.params<rss> {
        my $link = 'https://egeler.us' ~ $.request.uri.subst(/\?.+/, '');
        if $.request.params<tag> {
            $link ~= '?tag='~$.request.params<tag>;
        }
        $!feed = Syndication::RSS.new(:title('Egeler Blog'), :link($link),
                                      :description(''), :items(@rss-items));
    }
    %param<posts> = @tposts;
    %param<login> = $.session.data<local-login>;

    %param<page> = $page;
    %param<next-page> = '?page=' ~ ($page + 1) if @posts == $perpage;
    %param<prev-page> = '?page=' ~ ($page - 1) if $page > 0;

    return %param;
}
