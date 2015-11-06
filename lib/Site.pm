use Web::RF;
use Site::Tools;
use Config;

use Page::NotFound;
use Page::Redirect;
use Page::Login;

use Section::SAML;
use Section::Blog;

class Site is Web::RF::Router {
    method routes {
        $.route('',       Page::Redirect.new(:code(301), :url('/blog')));
        $.route('login',  Page::Login);
        $.route('blog/',  Section::Blog);
        $.route('saml2/', Section::SAML);
    }

    method before(:$request) {
        if $request.env<HTTP_HOST> eq 'retupmoca.com' {
            return Page::Redirect.go(:code(301), :url('https://egeler.us/blog/u/andrew'));
        }
        elsif $request.env<HTTP_HOST> ne 'egeler.us' || !$request.secure {
            return Page::Redirect.go(:code(301), :url('https://egeler.us/'));
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
                return [ 403, [], [] ];
            }
            default {
                return [ 500, [ "Content-Type" => 'text/plain' ], [ $_.gist ] ];
            }
        }
    }
}
