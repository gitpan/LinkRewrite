#!/usr/bin/perl 

use LinkRewrite;
use HTTP::Request;
use LWP::UserAgent;
use LWP::Simple;
use HTML::Parser;
use URI::URL ;
use Encode::HanConvert;
use HTML::Form;

sub print_cgi 
{
  foreach $pair (%ENV) {
    
     print $pair;
     print "<BR>\n";
      
}

}

$ua = LWP::UserAgent->new;

$user_agent=$ENV{'HTTP_USER_AGENT'};
$http_method=$ENV{'REQUEST_METHOD'};
if ($http_method eq "GET") {
 $buffer=$ENV{'QUERY_STRING'};
}
else
{
 read(STDIN,$buffer,$ENV{'CONTENT_LENGTH'});
 
}
print "content-type: text/html\n\n"; 
#&print_cgi;
#  print "$buffer\n\n";
$action=""; 
$myurl="";
@pairs = split(/&/,$buffer);
 $pair_idx=0;
 foreach $pair (@pairs) {
  if ($pair_idx>0) {
    $mynewurl .= $pair;  # append requested url
  }
  ($name,$value) = split(/=/,$pair);
  $value =~ s/\"//gi;
  $value =~ tr/+/ /;
  $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg;
  $value =~ s/<!--(.|\n)*-->//g;
  if ($name eq "org_action" ) {
    $action .= "url" . "=" . $value . "?";
  }
 elsif ($action ne "" ) {
    $action .= $name . "=" . $value . "&";
  }
   if ($name eq "url") {
  # print $value;
  }
  if ($pair_idx ==0) {
  $mynewurl = $value;   # get the first url it should be first value after first "=" 
   #print "pair_idx =0 $name=$mynewurl <br>\n\n"; 
}
  $pair_idx++;  
}
if ($action ne "") {
$mynewurl = $action ;
 #$mynewurl =~ s/org_action/http:\/\/www.easynet.com.hk\/wap-bin\/g2b.cgi?url/gi;
 #$mynewurl = $buffer;
 $mynewurl =~ s/org_action=//gi;
 $returl = big5_to_gb($mynewurl);
$mynewurl=$returl;
 $testbase = $mynewurl;
 $testbase =~ s/^url=//gi;
 $str="/";  # make the abs paths
 $u1 = URI::URL->new ($str,$testbase);
 $myurl = $u1->abs;
 
}
if ($myurl eq "") {
 $myurl = $value;
}
$myurl =~ s/http:\/\///gi;
$myurl = "http:\/\/" . $myurl;
$ua->agent($user_agent);
$mynewurl =~ s/%3A/:/gi;
$mynewurl =~ s/%25/%/gi;
$mynewurl =~ s/%2F/\//gi;
$mynewurl =~ s/%qm/\?/gi;
$mynewurl =~ s/^url=//i;
#print "$mynewurl\n\n";
#print "buffer = $buffer\n";
if ($mynewurl =~ m/$\.gif|$\.jpg|$\.png|$\.bmp|$\.xbm|$\.tif/i)  {
 if ($mynewurl !~ m/\?/i) {
 print "<html>";
 print "<body>";
 print "<img src=$mynewurl target=n1>\n";
 print "</body><html>";
 
}

}else
{


  my $req= HTTP::Request->new(GET => $mynewurl);


#print $myurl;
$ua->cookie_jar();
$res = $ua->request($req);
my $new_link = "http://chat.easynet.com.hk/cgi-bin/b2g_v1.cgi?url=";
$cgiurl = $new_link;
if ($res->is_success) {


 $myhtml = $res->content;
 $myproxybase =$res->base; 
}

if ($myhtml =~ /<meta/) {

require HTML::HeadParser;
 $p = HTML::HeadParser->new;
 $p->parse($myhtml);
 $myrefresh=$p->header('refresh');            # to access <meta http-equiv="Foo" content="...">
 $mynewbase=$p->header('base');
 print "<!-- $mynewbase -->\n\n";
 #$myurl=$mynewbase;
 $myrefresh =~ s/^(.*?);url=//gi;
 print "<!-- $myrefresh -->\n\n";
 if ($myrefresh  =~ /http/i) {

   my $req= HTTP::Request->new(GET => $myrefresh);
 $mynewurl=$myrefresh;
 $res = $ua->request($req);
 if ($res->is_success) {

  $myhtml = $res->content;
 }
}
}

#print "myproxybase = $myproxybase <br>";

#$myhtml =~ s/charset=gb2312/charset=big5/gi;
#$myhtml =~ s/x-x-big5/gb2312/gi;
print "<!-- Dear, it is a very alpha version ... may not work for CGI web pages <br>";
print "myurl = $myurl<br> GET=$mynewurl <br> -->\n";
if ($mynewurl ne '') { $myurl=$mynewurl; }
my $fqp= LinkRewrite->new($myurl);
$fqp->parse($myhtml);

$myhtml2= $fqp->get_doc();
$myhtml2=~ s/charset=gb2312/charset=big5/gi;
$myhtml2=~ s/utf-8/gb2312/gi;
#$myhtml2=~ s/x-x-big5/gb2312/gi;
$mybase = $fqp->get_base();
#print "<br>mybase=$mybase <br>";
#if (!$myhtml2 =~ /<base/ig) {

#$myhtml2 =~ s/<\/head>/<base href=$myurl><\/head>/gi;

#}
#$html= trad_to_gb($myhtml2);
$html= gb_to_big5($myhtml2);
print $html;

# $fqp->get_doc();


}




