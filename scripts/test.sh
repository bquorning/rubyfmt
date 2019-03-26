#!/bin/bash
set -ex

f_md5() {
    if [[ -z `which md5sum` ]]
    then
        md5
    else
        md5sum
    fi
}
STRING_LITERALS_EXPECTED=`ruby string_literals_stress_test.rb | f_md5`
STRING_LITERALS_ACTUAL=`ruby --disable=gems src/rubyfmt.rb string_literals_stress_test.rb | ruby | f_md5`
if [[ $STRING_LITERALS_EXPECTED != $STRING_LITERALS_ACTUAL ]]
then
    echo "string literals are broken"
    exit 1
fi

cp -r fixtures/2.5 fixtures/2.6
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
