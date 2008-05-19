#!/bin/bash
if [ -z "$2" ]; then 
  KEY="hex:E76B2413958B00E193"
else 
  KEY=$2
fi
echo "Test program $1 with test file and key $KEY. Run in test/ folder.."
echo "Crypt test file to test.crypt.$1.."
./$1 0 test/test.clear test/test.crypt.$1 $KEY
echo "Decrypt  test.crypt.$1 to test.decrypt.$1.."
./$1 1 test/test.crypt.$1 test/test.decrypt.$1 $KEY
echo "Compare result with original file"
md5sum test/test.clear
md5sum test/test.decrypt.$1
echo "Done."
exit
