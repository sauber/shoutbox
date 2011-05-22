package shoutbox;
use Dancer ':syntax';
use Dancer::Plugin::Ajax;
use Dancer::Plugin::Mongo;

# For debug
sub x {
  use Data::Dumper;
  Data::Dumper->Dump([$_[1]], ["*** $_[0]"]);
}

########################################################################
### MODEL
########################################################################

# mongo->databasename->tablename
our $db = mongo->shoutbox->shouts;

# Get a Specific Record by ID
#
sub getrecord {
  $db->find_one({ id => shift })
}

# Insert a new Record
# Takes hashref as parameter
# Add timestamp
#
sub addrecord {
  my $record = shift;
  $record->{'time'} = time;
  $db->insert( $record )
}

# List N newest records
#
sub listrecords {
  [
    map {
      id=>$_->{_id}{value},
      name=>$_->{name},
      message=>$_->{message},
      'time'=>$_->{'time'},
    },
    $db->query()->sort({ time => -1 })->limit(shift)->all
  ];
}


########################################################################
### CONTROLLER
########################################################################


our $VERSION = '0.1';

# A box of shout content
sub shoutbox {
  content_type 'text/html';
  template 'shouts', { records => listrecords(10) };
}

get '/' => sub {
  template 'index', { numrecords => 10, records => listrecords(10) };
};

ajax '/shout' => sub {
  if ( params->{name} and params->{message} ) {
    addrecord({
      name=>params->{name},
      message=>params->{message},
    });
  }
  #debug "Shout $user $mesg";
  #debug x 'records', listrecords(10);
  #to_json({ records=>listrecords(10) });
  #'Det var det';
  shoutbox();
};

ajax '/refresh' => sub {
  shoutbox();
};


true;
