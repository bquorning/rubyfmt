#!/bin/bash
set -ex

cp -r fixtures/2.5 fixtures/2.6
STRING_LITERALS_EXPECTED=`ruby string_literals_stress_test.rb | md5`
STRING_LITERALS_ACTUAL=`ruby --disable=gems src/rubyfmt.rb string_literals_stress_test.rb | ruby | md5`
if [[ $STRING_LITERALS_EXPECTED != $STRING_LITERALS_ACTUAL ]]
then
    echo "string literals are broken"
    exit 1
fi

for file in `ls fixtures/*_expected.rb` `ls fixtures/$(ruby -v | grep -o '\d\.\d')/*_expected.rb`
do
    time ruby --disable=gems src/rubyfmt.rb `echo $file | sed s/expected/actual/` > /tmp/out.rb
    diff /tmp/out.rb $file
    if [[ $? -ne 0 ]]
    then
        echo "got diff"
        exit 1
    fi
done
