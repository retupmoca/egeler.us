use HTMLPage;
use MIME::Base64;
use Auth::SAML2::AuthnRequest;
use Config;
use XML;

unit class Section::SAML::Auth does HTMLPage;

method html-status { 302 }
method html-headers { 
    my $redirect;
    if $.request.method eq 'POST' {
        my $sp-info = Config.get('saml-remote-sp');
        my $authn-str = MIME::Base64.decode-str($.request.params<SAMLRequest>);
        my $authn = Auth::SAML2::AuthnRequest.new;
        $authn.parse-xml(from-xml($authn-str).root);

        die "Unknown remote: " ~ $authn.issuer unless $sp-info{$authn.issuer};

        die "Wrong key: " ~ $authn.perl unless $authn.signed
                                                && $authn.signature-cert
                                                   eq $sp-info{$authn.issuer}<x509>;

        $.session.data<saml2-authn-request> = $authn;

        if $.session.data<local-login> {
            $redirect = '/saml2/authrespond';
        }
        else {
            $redirect = '/login?return=/saml2/authrespond';
        }
    }
    else {
        die "Must use HTTP-POST";
    }
    my @h;
    @h.push('Location' => $redirect);
    return @h;
}
