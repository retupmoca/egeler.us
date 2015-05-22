class Section::SAML;

use Section::SAML::Meta;
use Section::SAML::Auth;
use Section::SAML::AuthRespond;

method dispatch($basepath) {
    my @d;
    @d.push([
        -> $r, $s {
            $r.uri eq $basepath ~ '/metadata';
        }, Section::SAML::Meta]);
    @d.push([
        -> $r, $s {
            $r.uri eq $basepath ~ '/auth';
        }, Section::SAML::Auth]);
    @d.push([
        -> $r, $s {
            $r.uri eq $basepath ~ '/authrespond';
        }, Section::SAML::AuthRespond]);
    return @d;
}
