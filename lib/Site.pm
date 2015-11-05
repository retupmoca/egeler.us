unit class Site;

use Path::Router;
use Crust::Request;

use Site::Tools;
use Config;

use Page::NotFound;
use Page::Redirect;
use Page::Login;

use Section::SAML;
use Section::Blog;

class Site::Main is Site::Router {
    method routes {
        $.route('',       Page::Redirect.new(:code(301), :url('/blog')));
        $.route('login',  Page::Login);
        $.route('blog/',  Section::Blog);
        $.route('saml2/', Section::SAML);
    }
}

has $!router;
submethod BUILD {
    $!router = Site::Main.new;
}

method handle(%env) {
    # TODO: put basic system load checker / fast-path bailout here
    # (not that this is ever going to get more than about 5 pageviews...ever)
    # if load-high return [ 503, [], [ 'oh god it burns' ]];

    my $request = Crust::Request.new(%env);

    # initial redirects
    if %env<HTTP_HOST> eq 'retupmoca.com' {
        return Page::Redirect.go(:code(301), :url('https://egeler.us/blog/u/andrew'));
    }
    elsif %env<HTTP_HOST> ne 'egeler.us' || !$request.secure {
        return Page::Redirect.go(:code(301), :url('https://egeler.us/'));
    }
    else {
        my $uri = $request.request-uri.subst(/\?.+$/, '');

        my $page = $!router.router.match($uri);
        my $resp;
        if $page {
             $resp = $page.target.handle(:$request, :mapping($page.mapping));
        }
        else {
            return Page::NotFound.handle(:$request);
        }
        return $resp;
    }

    CATCH {
        when X::BadRequest {
            # assume that the URI is valid, but the method (or similar) was not
            return [ 400, [], []];
        }
        when X::PermissionDenied {
            return [ 403, [], []];
        }
        default {
            return [ 500, [ "Content-Type" => 'text/plain' ], [ $_.gist ] ];
        }
    }
}
