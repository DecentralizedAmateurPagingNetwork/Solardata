#!/usr/bin/perl
# Perl-Skript zum Transfer Sonnenaktivität -> DAPNET
#  
# developed since 01/10/2018 by Michael DG5MM
# rev: 0.1
#
#
# todo:
#
# required:	libxml-simple-perl, REST::Client

use strict;
use LWP;
use XML::Simple;
use REST::Client;
use MIME::Base64;
use utf8;

my $solardataurl = 'http://www.hamqsl.com/solarxml.php';# URL N0NBH
my $dapnethost = 'hampager.de';				# DAPNET-Server-Host
my $dapnetport = '8080';				# DAPNET-Server-Port
my $dapnetuser = 'xxxx';				# Benutzername am DAPNET-Server
my $dapnetpw = 'xxxx';				# Passwort am DAPNET-Server

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET=>$solardataurl);
my $res = $ua->request($req);
my $data = XML::Simple->new()->XMLin($res->content);
my $c = REST::Client->new();

$c->setHost("$dapnethost:$dapnetport");
$c->addHeader('Authorization'=>'Basic ' . encode_base64("$dapnetuser:$dapnetpw"));
$c->addHeader('charset', 'UTF-8');
$c->addHeader('Content-Type', 'application/json');
$c->addHeader('Accept', 'application/json');
      
my $nachricht = "SFI " . $data->{"solardata"}->{"solarflux"} . "  SN " . $data->{"solardata"}->{"sunspots"};
while (length($nachricht) < 20) {
  $nachricht .= ' ';
}
$nachricht .= "A" . $data->{"solardata"}->{"aindex"} . "  K" . $data->{"solardata"}->{"kindex"} . "  MUF " . $data->{"solardata"}->{"muf"};
while (length($nachricht) < 40) {
  $nachricht .= ' ';
}
$nachricht .= "X-Ray" . $data->{"solardata"}->{"xray"};
while (length($nachricht) < 60) {
  $nachricht .= ' ';
}
$nachricht .= "(N0NBH: hamqsl.com)";
$c->POST('/news', '{"rubricName": "dxcond", "text": "'.$nachricht.'", "number": 1 }', {"Content-type"=>'application/json'});
