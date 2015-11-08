use MIME::Base64;
use Section::SAML::AuthRespond;
use Page::Login;
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

    my $authrespond = $.url-for(Section::SAML::AuthRespond);
    if $request ~~ Authed {
        $redirect = $authrespond;
    }
    else {
        $redirect = $.url-for(Page::Login) ~ '?return=' ~ $authrespond;
    }

    return Web::RF::Redirect.go(:code(302), :url($redirect));
}
