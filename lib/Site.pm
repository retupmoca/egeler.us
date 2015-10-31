unit class Site;

use Path::Router;
use Crust::Request;

use Session;
use Config;

use Page::NotFound;
use Page::Redirect;
use Page::Login;

use Section::SAML;
use Section::Blog;

has @!dispatch-list;
has $!router;
has $!sessions;

submethod BUILD() {
    $!router = Path::Router.new;
    # we have no homepage; redirect to the blog
    $!router.add-route('', target => Page::Redirect.new(:code(301), :url('/blog')));
    $!router.add-route('login', target => Page::Login);
    $!router.include-router('blog/' => Section::Blog.router);
    $!router.include-router('saml2/' => Section::SAML.router);

    $!sessions = SessionManager.new;
}

method handle(%env) {
    # TODO: put basic system load checker / fast-path bailout here
    # (not that this is ever going to get more than about 5 pageviews...ever)
    # if load-high return [ 503, [], [ 'oh god it burns' ]];

    my $request = Crust::Request.new(%env);

    # initial redirects
    if %env<HTTP_HOST> eq 'retupmoca.com' {
        return Page::Redirect.new(:code(301), :url('https://egeler.us/blog/u/andrew')).handle(:$request);
    }
    elsif %env<HTTP_HOST> ne 'egeler.us' || !%env<HTTPS> {
        return Page::Redirect.new(:code(301), :url('https://egeler.us/')).handle(:$request);
    }
    else {
        my $session = $!sessions.load($request.cookies<session>);
        my $session;
        my @headers;
        unless $session {
            $session = $!sessions.create();
            @headers.push('Set-Cookie' => 'session=' ~ $session.id ~ '; path=/');
        }

        my $uri = $request.request-uri.subst(/\?.+$/, '');

        my $page = $!router.match($uri);
        my $resp;
        if $page {
             $resp = $page.target.handle(:$request, :$session);
        }
        else {
            return Page::NotFound.handle(:$request, :$session);
        }
        $resp[1].append: @headers;
        return $resp;
    }

    CATCH {
        default {
            # display_errors = On
            # TODO: Stop being PHP. Nobody likes that guy.
            return [500, [ 'Content-Type' => 'text/plain' ],
                         [ $_ ~ "\n" ~ $_.backtrace ]];
        }
    }
}
