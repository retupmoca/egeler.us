use Web::RF;
use Config;

use Page::NotFound;
use Page::Login;

use Section::SAML;
use Section::Blog;

class Site is Web::RF::Router {
    method routes {
        $.route('',       Web::RF::Redirect.new(:code(301), :url('/blog')));
        $.route('login',  Page::Login);
        $.route('blog/',  Section::Blog);
        $.route('saml2/', Section::SAML);
    }

    method before(:$request) {
        if $request.env<HTTP_HOST> eq 'retupmoca.com' {
            return Web::RF::Redirect.go(:code(301), :url('https://egeler.us/blog/u/andrew'));
        }
        elsif $request.env<HTTP_HOST> ne 'egeler.us' || !$request.secure {
            return Web::RF::Redirect.go(:code(301), :url('https://egeler.us/'));
        }
    }

    method error(:$request, :$exception) {
        given $exception {
            when X::NotFound {
                return Page::NotFound.handle(:$request);
            }
            when X::BadRequest {
                return [ 400, [], [] ];
            }
            when X::PermissionDenied {
                if $request ~~ Anon & Get {
                    return Web::RF::Redirect.go(302, '/login?return='~$request.request-uri);
                }
            }
            default {
                return [ 500, [ "Content-Type" => 'text/plain' ], [ $_.gist ] ];
            }
        }
    }
}
