use MIME::Base64;
use Site::Tools;
use Web::RF;
use Auth::SAML2::AuthnRequest;
use Config;
use XML;

unit class Section::SAML::Auth is Web::RF::Controller;

method handle(Post :$request) { 
    my $redirect;
    my $sp-info = Config.get('saml-remote-sp');
    my $authn-str = MIME::Base64.decode-str($request.parameters<SAMLRequest>);
    my $authn = Auth::SAML2::AuthnRequest.new;
    $authn.parse-xml(from-xml($authn-str).root);

    die X::BadRequest.new unless $sp-info{$authn.issuer};

    die X::BadRequest.new unless $authn.signed
                                            && $authn.signature-cert
                                               eq $sp-info{$authn.issuer}<x509>;

    $request.session.set('saml2-authn-request', $authn);

    if $request ~~ Authed {
        $redirect = '/saml2/authrespond';
    }
    else {
        $redirect = '/login?return=/saml2/authrespond';
    }

    return Web::RF::Redirect.go(:code(302), :url($redirect));
}
