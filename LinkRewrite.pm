package LinkRewrite;
use HTTP::Request;
use LWP::UserAgent;
use LWP::Simple;
use HTML::Parser;
use URI::URL ;
@LinkRewrite::ISA = qw(HTML::Parser);
# 
# takes one optional argument, a base url.  typically this will be the
# url you fetched the contents from.
sub new
{
    my $class = shift;
    my $self = HTML::Parser->new();
    bless $self, $class;
    # what is the base URL we should try to absolutize to?
    $self->{_fqp_base} = shift;
    # an accumulator for the output
    $self->{_fqp_out} = '';
    # and a flag to tell us whether or not we're in the <HEAD></HEAD> block
    $self->{_fqp_in_head} = 0;
    $self->{_fqp_in_base} = 0;
    return $self;
}

# the "start" method is the only one that needs brains.  and the "end"
# method needs a small brain, since we need to track whether or not
# we're in the <HEAD> section.
sub start
{ 
    my ($self, $tag, $attr, $attrseq, $orig_text) = @_;

     SWITCH :     {

	 if ($tag eq 'title') { 
			
		$orig_text =~ s/<title>/<title>EasyNet:::/gi;
		$self->{_fqp_out} .=  $orig_text;
                last SWITCH; }

     #    if ($self->{_fqp_in_head} && $tag eq 'base') {
      #          $self->{_fqp_base} = $attr->{href};
       #     $self->{_fpp_out} .= $orig_text;
       #         $self->{_fqp_in_base} = 1;
        #        last SWITCH; }

    if ((exists $attr->{href} && ($tag ne 'img' || $tag ne 'link')) || $tag eq 'frame' || $tag eq 'iframe' || $tag eq 'script' || $tag eq 'form'  || $tag eq 'a' ) {
          #$self->{_fqp_out} .= "<!-- find tags --><br>";       
  if ($orig_text =~ /language=/i) {
               $self->{_fqp_out} .= $orig_text;
               $self->{_fqp_out} .= "<!-- find language -->";
               last SWITCH;
            }
         if ($orig_text =~ /<script>/gi) {
               $self->{_fqp_out} .= $orig_text;
               last SWITCH;
           }
              	
          for my $link_attr (qw/href src area action/) 
              { 
                  $self->{_fqp_out} .="<!-- find link_attr= $link_attr-->\n";
                  next unless exists $attr->{$link_attr};
                  my $orig_url = $attr->{$link_attr};
                 
                my $new_url = url($attr->{$link_attr}, $self->{_fqp_base})->abs();
                my $real_base = $new_url;
            
             if ($link_attr eq "action") {
              $new_url = "http://www.easynet.com.hk/wap-bin/work1/g2b-v2.cgi?";

             }
            else {
             $new_url = "http://www.easynet.com.hk/wap-bin/work1/g2b-v2.cgi?url=" . $new_url;	
             }
           #   print "<!-- Debug 0 -->\r\n";
           #   print "<!-- orig_text $orig_text -->\r\n";   
             $orig_url =~ s/\?/%qm/i;
             $new_url =~ s/\?/%qm/i;
             $orig_text =~ s/\?/%qm/i;
              
	     $orig_text =~ s/&/%2D/gi;
             $new_url =~ s/&/%2D/gi;
             $orig_url =~ s/&/%2D/gi;	

	     $orig_text =~ s/=/%3D/gi;
             $new_url =~ s/=/%3D/gi;
             $orig_url =~ s/=/%3D/gi;	


             $orig_text =~ s{($link_attr)\s*%3D\s*([\"\']?)$orig_url\2}
                               {$1="$new_url"}i;
                
            
              $orig_text =~ s/%qm/\?/i;
              $orig_text =~ s/%2D/&/gi;
              $orig_text =~ s/%3D/=/gi;
            #   print "<!-- DEBUG --->\r\n"; 
            #   print "<!-- new_url= $new_url -->\r\n";
            #   print "<!-- link_attr $link_attr -->\r\n";
            #   print "<!-- orig_url $orig_url -->\r\n";
            #   print "<!-- orig_text $orig_text -->\r\n";
              
              $self->{_fqp_out} .= $orig_text;
		if ($orig_text =~ /\saction/i) {
		 $self->{_fqp_out} .= "\n<input type=hidden name=org_action value=\"$real_base\">\n";
		 $self->{_fqp_out} .= "\n<input type=hidden name=org_base value=\"$self->{_fqp_base}\">";

                  }

              
             #  $self ->{_fqp_out} .= $new_url;
		}
	     
              last SWITCH;
            }   

         if ((exists $attr->{src}  && $tag eq 'img') || (exists $attr->{background} && ($tag eq 'body' || $tag eq 'td')) || ($tag eq 'form' ) || ($tag =~ m/link embed/ )  ) {
              for my $link_attr (qw/src background href/)
              { 

		next unless exists $attr->{$link_attr};
                  my $orig_url = $attr->{$link_attr};
                  my $new_url = url($attr->{$link_attr},$self->{_fqp_base})->abs();
       
                $orig_text =~ s{($link_attr)\s*=\s*([\"\']?)$orig_url\2}
                               {$1="$new_url"}i;
                
              $self->{_fqp_out} .= $orig_text;
             }
              last SWITCH;
              } 
             
         $self->{_fqp_out} .= $orig_text;
 }
}

sub end
{
    my ($self, $tag, $orig_text) = @_;

    if ($tag eq 'head')
    {
        $self->{_fqp_in_head} = 0;
    }

    if ($self->{_fqp_in_base} = 0) {

      $self->{_fqp_out} .= "<base href=" . $self->{$link_url} . ">" 

    }

    $self->{_fqp_out} .= $orig_text;
}

# the rest of the overrides just copy stuff along
sub default
{
  my ($self, $text) = @_;
  $self->{_fqp_out} .= $text;
}

sub declaration
{
    my ($self, $decl) = @_;
    $self->{_fqp_out} .= "<!" . $decl . "testing" . ">";
}

sub text
{
    my ($self, $text) = @_;
    $self->{_fqp_out} .= $text;
}

sub comment
{
    my ($self, $comment) = @_;
    $self->{_fqp_out} .= "<!--" . $comment . "-->" ;
}

# and finally, to get the results...

sub get_doc
{
    my $self = shift;
    return $self->{_fqp_out};
}

sub get_base
{
   return $self->{_fqp_base};

}
1;
