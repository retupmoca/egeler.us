use Web::RF;
use Crust::Request;
use Page::Redirect;

unit module Site::Tools;

subset Authed of Crust::Request is export where { so $_.session.data<local-login> }; 
subset Anon of Crust::Request is export where { !($_.session.data<local-login>) }; 

class X::PermissionDenied is Exception is export { }

class Web::RF::Controller::Authed is Web::RF::Controller is export {
    multi method handle(Get :$request where Anon) {
        return Page::Redirect.go(:code(302), :url('/login?return='~$request.request-uri));
    }
    multi method handle(Post :$request where Anon) {
        # we can't redirect to login and back without losing the post data
        # so we blow up instead
        die X::BadRequest.new;
    }
}
