#!/bin/bash

# find_missing_files.sh
# by Graeme West
# Based on the answer kindly supplied by 'Unknown' at StackOverflow: 
# http://stackoverflow.com/questions/3006014/finding-missing-files-by-checksum
#
#
# Compares the files in two directories to find ones which are present in the
# source but not in the destination. Useful for data migrations.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details,
# which is available at www.gnu.org
 
# Set these to the directories you'd like to compare.

source_dir="$1/"
dest_dir="$2/"
work_dir=$(mktemp --directory --tmpdir fmfXXXXXXX)

echo "Source dir: $source_dir">cmp_dirs.txt
echo "Dest dir: $dest_dir">>cmp_dirs.txt

# Files into which to write checksums of all files.
# These will be cleared before output begins.
source_files="$work_dir/cmp_source_files_unsorted.txt"
dest_files="$work_dir/cmp_dest_files_unsorted.txt"

# for sorted checksum lists - these are used to make the comparisons

SOURCE="$work_dir/cmp_source_files_sorted.txt"
DEST="$work_dir/cmp_dest_files_sorted.txt"

# The file which should contain the final output.
# This will be cleared before output begins.
output_file1="cmp_files_only_in_source.txt"
output_file2="cmp_files_only_in_dest.txt"


# right, let's get on with it.

find $source_dir -type f -exec sha512sum {} > $source_files \;
find $dest_dir -type f -exec sha512sum {} > $dest_files \;
sort $source_files > $SOURCE
sort $dest_files > $DEST

for sha1 in `comm -23 <(cat $SOURCE | awk '{print $1}') <(cat $DEST | awk '{print $1}')`; do grep $sha1 $SOURCE; done | awk '{print $2}'|sort|uniq> $output_file1
for sha1 in `comm -13 <(cat $SOURCE | awk '{print $1}') <(cat $DEST | awk '{print $1}')`; do grep $sha1 $DEST; done | awk '{print $2}'|sort|uniq> $output_file2

echo "Finished finding missing files. Output written to $output_file1 and $output_file2"

rm -rf "$work_dir"
