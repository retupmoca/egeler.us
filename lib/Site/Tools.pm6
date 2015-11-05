use Crust::Request;
use Path::Router;

unit module Site::Tools;

subset Authed of Crust::Request is export where { so $_.session.data<local-login> }; 
subset Anon of Crust::Request is export where { !($_.session.data<local-login>) }; 

subset Post of Crust::Request is export where { $_.method eq 'POST' };
subset Get of Crust::Request is export where { $_.method eq 'GET' };

class X::PermissionDenied is Exception is export { }
class X::BadRequest is Exception is export { }

class Site::Controller is export {
    multi method handle {
        die X::BadRequest.new;
    }
}

class Site::Controller::Authed is Site::Controller is export {
    multi method handle(Get :$request where Anon) {
        return Page::Redirect.go(:code(302), :url('/login?return='~$request.request-uri));
    }
    multi method handle(Post :$request where Anon) {
        # we can't redirect to login and back without losing the post data
        # so we blow up instead
        die X::BadRequest.new;
    }
}

class Site::Router is export {
    has $.router;

    submethod BUILD {
        $!router = Path::Router.new;
        self.routes();
    }

    multi method route(Str $path, Site::Controller $target) {
        $!router.add-route($path, target => $target);
    }
    multi method route(Str $path, Site::Router:D $target) {
        $!router.include-router($path => $target.router);
    }
    multi method route(Str $path, Site::Router:U $target) {
        self.route($path, $target.new);
    }

    method routes {
        ...;
    }
}
