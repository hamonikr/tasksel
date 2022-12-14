#!/usr/bin/perl -w
#
# ubuntu-seeds outdir suite flavour ...
#
# Process Task-* fields from the seeds for each of the specified flavours,
# and turn them into task description files. The Task field in the resulting
# task description file will be the seed name, except for per-derivative
# seeds (see below). Each field has "Task-" stripped from the front and is
# then used verbatim, with the following exceptions:
#
#   Task-Name:
#     This field overrides the usual task name computation (including
#     Task-Per-Derivative, below).
#
#   Task-Per-Derivative:
#     Seeds with this field set to a true value will have the seed name and
#     a dash prepended to the task name (so "desktop" in the "ubuntu" seeds
#     becomes "ubuntu-desktop"). Seeds without this field will only be
#     processed the first time they are encountered in command-line order.
#
#   Task-Extended-Description:
#     The content of this field will be used as the continuation of the
#     Description field.

use strict;
use File::Path;
use File::Temp qw(tempdir);

my $seed_base='git+ssh://git.launchpad.net/~ubuntu-core-dev/ubuntu-seeds/+git';
my $kubuntu_seed_base='bzr+ssh://bazaar.launchpad.net/~kubuntu-dev/ubuntu-seeds';
my $xubuntu_seed_base='git+ssh://git.launchpad.net/~xubuntu-dev/ubuntu-seeds/+git';
my $mythbuntu_seed_base='bzr+ssh://bazaar.launchpad.net/~mythbuntu-dev/ubuntu-seeds';
my $ubuntustudio_seed_base='git+ssh://git.launchpad.net/~ubuntustudio-dev/ubuntu-seeds/+git';
my $lubuntu_seed_base='git+ssh://git.launchpad.net/~lubuntu-dev/ubuntu-seeds/+git';
my $ubuntu_gnome_seed_base='bzr+ssh://bazaar.launchpad.net/~ubuntu-gnome-dev/ubuntu-seeds';
my $ubuntu_mate_seed_base='bzr+ssh://bazaar.launchpad.net/~ubuntu-mate-dev/ubuntu-seeds';
my $ubuntu_budgie_seed_base='bzr+ssh://bazaar.launchpad.net/~ubuntubudgie-dev/ubuntu-seeds';
my $outdir=shift or die "no output directory specified\n";
my $suite=shift or die "no suite specified\n";
my @flavours=@ARGV;
@flavours >= 1 or die "no flavours specified\n";

if (-d $outdir) {
	rmtree $outdir or die "can't remove old $outdir: $!\n";
}
mkpath $outdir or die "can't create $outdir: $!\n";

open README, '>', "$outdir/README"
	or die "can't open $outdir/README for writing: $!\n";
print README <<EOF or die "can't write to $outdir/README: $!\n";
The files in this directory are automatically generated and should not
normally be edited by hand. See ubuntu-seeds.pl and Makefile in the parent
directory.
EOF
close README or die "can't close $outdir/README: $!\n";

my $tempdir=tempdir('tasksel-XXXXXX', TMPDIR => 1, CLEANUP => 1);
system('bzr', 'init-repo', $tempdir);

my %seen_seed;

for my $flavour (@flavours) {
	my $checkout="$tempdir/checkout-$flavour";
	my @command=('git', 'clone');
	my @bzr_command=('bzr', 'branch');
	if ($flavour eq 'kubuntu' or $flavour eq 'kubuntu-active') {
		@command=@bzr_command;
		push @command, "$kubuntu_seed_base/$flavour.$suite";
	} elsif ($flavour eq 'xubuntu') {
		push @command, "$xubuntu_seed_base/$flavour", '-b', $suite;
	} elsif ($flavour eq 'mythbuntu') {
		push @command, "$mythbuntu_seed_base/$flavour", '-b', $suite;
	} elsif ($flavour eq 'ubuntustudio') {
		push @command, "$ubuntustudio_seed_base/$flavour", '-b', $suite;
	} elsif ($flavour eq 'lubuntu') {
		push @command, "$lubuntu_seed_base/$flavour", '-b', $suite;
	} elsif ($flavour eq 'ubuntu-mate') {
		@command=@bzr_command;
		push @command, "$ubuntu_mate_seed_base/$flavour.$suite";
	} elsif ($flavour eq 'ubuntu-budgie') {
		@command=@bzr_command;
		push @command, "$ubuntu_budgie_seed_base/$flavour.$suite";
	} elsif ($flavour eq 'vanilla-gnome') {
		@command=@bzr_command;
		push @command, "$ubuntu_gnome_seed_base/ubuntu-gnome.$suite";
	} else {
		push @command, "$seed_base/$flavour", '-b', $suite;
	}
	push @command, $checkout;
	my $ret=system(@command);
	if ($ret != 0) {
		my $commandstr=join(' ', @command);
		die "'$commandstr' failed with exit status $ret\n";
	}

	my @seeds;
	local *STRUCTURE;
	open STRUCTURE, "$checkout/STRUCTURE"
		or die "can't open $checkout/STRUCTURE: $!\n";
	while (<STRUCTURE>) {
		chomp;
		next if /^#/;
		if (/^(.*?):/) {
			push @seeds, $1;
		}
	}
	close STRUCTURE;

	for my $seed (@seeds) {
		my %fields;
		my @fieldorder;
		local *SEED;
		open SEED, "$checkout/$seed"
			or die "can't open $checkout/$seed: $!\n";
		while (<SEED>) {
			chomp;
			next unless /^Task-(.*?):\s*(.*)/i;
			push(@{$fields{lc $1}}, $2);
			push @fieldorder, $1;
		}
		close SEED;
		next unless keys %fields;
		next unless exists $fields{'description'};

		my $task=$seed;
		if ($fields{'name'}) {
			$task=$fields{'name'}[0];
		} elsif ($fields{'per-derivative'}) {
			$task="$flavour-$seed";
		} elsif (exists $seen_seed{$seed}) {
			next;
		}
		$seen_seed{$seed} = 1;

		open TASK, '>', "$outdir/$task"
			or die "can't open $outdir/$task for writing: $!\n";
		print TASK "Task: $task\n"
			or die "can't write to $outdir/$task: $!\n";
		for my $field (@fieldorder) {
			my $lcfield=lc $field;
			next if $lcfield eq 'name' or
				$lcfield eq 'per-derivative' or
				$lcfield eq 'extended-description';
			if ($lcfield eq 'key') {
				# must be multi-line
				my @values=split /,*\s+/, $fields{$lcfield}[0];
				print TASK "$field:\n" .
					   join('', map(" $_\n", @values))
					or die "can't write to " .
					       "$outdir/$task: $!\n";
			} else {
				print TASK "$field: $fields{$lcfield}[0]\n"
					or die "can't write to " .
					       "$outdir/$task: $!\n";
			}
			if ($lcfield eq 'description') {
				if (exists $fields{'extended-description'}) {
					for my $line (@{$fields{'extended-description'}}) {
						print TASK " $line\n"
							or die "can't write to " .
						       "$outdir/$task: $!\n";
					}
				} else {
					print TASK " $fields{description}[0]\n"
						or die "can't write to " .
						       "$outdir/$task: $!\n";
				}
			}
		}
		unless (exists $fields{packages}) {
			print TASK "Packages: task-fields\n"
				or die "can't write to $outdir/$task: $!\n";
		}
		close TASK or die "can't close $outdir/$task: $!\n";
	}

	if ($flavour eq 'ubuntustudio') {
		rename "$tempdir/.bzr.save", "$tempdir/.bzr";
	}
}
