use Web::RF;
use Section::Blog::Data::Post;
use Syndication;
use Site::Template;

unit class Section::Blog::Home is Web::RF::Controller;

method handle(:$request, :%mapping) {
    my %param;
    my $feed;
    my $user = %mapping<user>;
    my @rss-items;

    my $params = $request.parameters;

    my $perpage = 25;
    my $page = $params<page> || 0;

    my @posts = Section::Blog::Data::Post.search(:author($user), 
                                                 :tag($params<tag>),
                                                 :count($perpage),
                                                 :offset($perpage * $page));
    my @tposts;
    for @posts -> $p {
        if $params<rss> {
            @rss-items.push: Syndication::RSS::Item.new(:title($p.title),
                                                        :link('https://egeler.us/blog/p/'~$p.id),
                                                        :summary($p.body),
                                                        :author($p.author),
                                                        :updated($p.posted));
        }
        my %d;

        if $request.user-id
           && $p.author eq $request.user-id {
            %d<own-post> = 1;
        }

        %d<body> = $p.html-body;
        %d<id> = $p.id;
        %d<title> = $p.title;
        %d<tags> = $p.tags.join(',');
        %d<tags_list> = Array.new($p.tags.map({ ( tag => $_, comma => 1 ).hash.item }));
        %d<tags_list>[*-1]<comma> = 0 if $p.tags;
        %d<author> = $p.author;
        %d<posted> = $p.posted.Str.subst(/Z$/, '').subst(/T/, ' ');

        @tposts.push(%d);
    }
    if $params<rss> {
        my $link = 'https://egeler.us' ~ $request.request-uri.subst(/\?.+$/, '');
        if $params<tag> {
            $link ~= '?tag='~$params<tag>;
        }
        $feed = Syndication::RSS.new(:title('Egeler Blog'), :link($link),
                                      :description(''), :items(@rss-items));
    }
    %param<posts> = @tposts;
    %param<login> = $request.user-id;

    %param<page> = $page;
    %param<next-page> = '?page=' ~ ($page + 1) if @posts == $perpage;
    %param<prev-page> = '?page=' ~ ($page - 1) if $page > 0;

    if $params<rss> {
        return [ 200, [ 'Content-Type' => 'text/xml; charset=utf-8' ], [ ~$feed ]];
    }
    else {
        my $tfile = 'blog.tmpl';
        if $user && "/home/$user/blog/home.tmpl".IO.e {
            $tfile = "/home/$user/blog/home.tmpl";
        }
        return [ 200, [ 'Content-Type' => 'text/html' ],
                [ Site::Template.new(:file($tfile)).render(%param) ] ];
    }
}
