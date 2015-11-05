unit module Site::Tools;

subset Authed of Crust::Request is export where { so $_.session.data<local-login> }; 
subset Anon of Crust::Request is export where { !($_.session.data<local-login>) }; 

subset Post of Crust::Request is export where { $_.method eq 'POST' };
subset Get of Crust::Request is export where { $_.method eq 'GET' };

multi sub trait_mod:<is> (Method:D $meth, Bool :$authed!) is export {
    $meth.wrap(method (:$request) {
        if !$request.session.data<local-login> {
            return Page::Redirect.go(:code(302),
                                     :url('/login?return='~$request.request-uri));
        }
        nextsame;
    });
}

class X::PermissionDenied is Exception { }
class X::BadRequest is Exception { }
