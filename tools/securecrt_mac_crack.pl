#!/usr/bin/perl

use strict;
use warnings;
use 5.01;



sub license {
	print "\n".
	"License:\n\n".
	"\tName:\t\tbleedfly\n".
	"\tCompany:\tbleedfly.com\n".
	"\tSerial Number:\t03-29-002542\n".
	"\tLicense Key:\tADGB7V 9SHE34 Y2BST3 K78ZKF ADUPW4 K819ZW 4HVJCE P1NYRC\n".
	"\tIssue Date:\t09-17-2013\n\n\n";
}

sub usage {
    print "\n".
	"help:\n\n".
	"\tperl securecrt_mac_crack.pl <file>\n\n\n".
	"\tperl securecrt_mac_crack.pl /usr/bin/SecureCRT\n\n\n".
    "\n";

	&license;

    exit;
}
&usage() if ! defined @ARGV ;


my $file = $ARGV[0];

open FP, $file or die 'can not open file $!';
binmode FP;

open TMPFP, '>', '/tmp/.securecrt.tmp' or die 'can not open file $!';

my $buffer;
my $unpack_data;
my $crack = 0;

while(read(FP, $buffer, 1024)) {
	$unpack_data = unpack('H*', $buffer);
	if ($unpack_data =~ m/785782391ad0b9169f17415dd35f002790175204e3aa65ea10cff20818/) {
		$crack = 1;
		last;
	}
	if ($unpack_data =~ s/6e533e406a45f0b6372f3ea10717000c7120127cd915cef8ed1a3f2c5b/785782391ad0b9169f17415dd35f002790175204e3aa65ea10cff20818/ ){
		$buffer = pack('H*', $unpack_data);
		$crack = 2;
	}
	syswrite(TMPFP, $buffer, length($buffer));
}

close(FP);
close(TMPFP);



given ($crack) {
	when (1) {
		unlink '/tmp/.securecrt.tmp' or die 'can not delete files $!';
		say "It has been cracked";
		&license;
		exit 1;
	}
	when (2) {
		rename '/tmp/.securecrt.tmp', $file or die 'Insufficient privileges, please switch the root account.';
		chmod 0755, $file or die 'Insufficient privileges, please switch the root account.';
		say 'crack successful';
		&license;
	}
	default { die 'error' }
}
