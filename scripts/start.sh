#!/bin/bash
echo Initializing....

killall -KILL screen
sleep 5

echo Starting All Builds...
screen -d -m -S builder -t admin
screen -X -S builder -p 0 stuff "bash\n"
screen -X -S builder -p 0 stuff "echo Hello\n"

screen -X -S builder screen -t linux-x86 1
screen -X -S builder -p 1 stuff "bash\n"
screen -X -S builder -p 1 stuff "ssh cross-linux-x86\n"
screen -X -S builder -p 1 stuff "hostname\n"
screen -X -S builder -p 1 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-x86-32bit linux-generic32 \"-fPIE -m32\"\n"

screen -X -S builder screen -t linux-x64 2
screen -X -S builder -p 2 stuff "bash\n"
screen -X -S builder -p 2 stuff "ssh cross-linux-x64\n"
screen -X -S builder -p 2 stuff "hostname\n"
screen -X -S builder -p 2 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-x86-64bit linux-x86_64 \"-fPIE -m64\"\n"

screen -X -S builder screen -t linux-arm32 3
screen -X -S builder -p 3 stuff "bash\n"
screen -X -S builder -p 3 stuff "ssh cross-linux-arm32\n"
screen -X -S builder -p 3 stuff "hostname\n"
screen -X -S builder -p 3 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-arm-32bit \"linux-generic32 no-asm\" \"-fPIE -fno-builtin-ffs\"\n"

screen -X -S builder screen -t linux-armeabi32 4
screen -X -S builder -p 4 stuff "bash\n"
screen -X -S builder -p 4 stuff "ssh cross-linux-armeabi32\n"
screen -X -S builder -p 4 stuff "hostname\n"
screen -X -S builder -p 4 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-armeabi-32bit linux-generic32 \"-fPIE -fno-builtin-ffs\"\n"

screen -X -S builder screen -t linux-mipsel32 5
screen -X -S builder -p 5 stuff "bash\n"
screen -X -S builder -p 5 stuff "ssh cross-linux-mipsel32\n"
screen -X -S builder -p 5 stuff "hostname\n"
screen -X -S builder -p 5 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-mipsel-32bit linux-generic32 \"-fPIE\"\n"

screen -X -S builder screen -t linux-ppc32 6
screen -X -S builder -p 6 stuff "bash\n"
screen -X -S builder -p 6 stuff "ssh cross-linux-ppc32\n"
screen -X -S builder -p 6 stuff "hostname\n"
screen -X -S builder -p 6 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-ppc-32bit linux-generic32 \"-fPIE\"\n"

#screen -X -S builder screen -t linux-sh32 7
#screen -X -S builder -p 7 stuff "bash\n"
#screen -X -S builder -p 7 stuff "ssh cross-linux-sh32\n"
#screen -X -S builder -p 7 stuff "hostname\n"
#screen -X -S builder -p 7 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-sh4-32bit linux-generic32 \"-fPIE\"\n"

screen -X -S builder screen -t freebsd-x86 8
screen -X -S builder -p 8 stuff "bash\n"
screen -X -S builder -p 8 stuff "ssh cross-freebsd-x86\n"
screen -X -S builder -p 8 stuff "hostname\n"
screen -X -S builder -p 8 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix freebsd-x86-32bit BSD-generic32 \"-fPIE\"\n"

screen -X -S builder screen -t freebsd-x64 9
screen -X -S builder -p 9 stuff "bash\n"
screen -X -S builder -p 9 stuff "ssh cross-freebsd-x64\n"
screen -X -S builder -p 9 stuff "hostname\n"
screen -X -S builder -p 9 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix freebsd-x86-64bit BSD-x86_64 \"-fPIE\"\n"



cat <<\EOF > /crossnfs/_solaris_sparc32_tmp.sh
#!/bin/bash
/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix solaris-sparc-32bit solaris-sparcv9-gcc "-fPIE -m32" && /crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix solaris-sparc-64bit "solaris64-sparcv9-gcc no-asm" "-fPIE -m64"
EOF
chmod 755 /crossnfs/_solaris_sparc32_tmp.sh

screen -X -S builder screen -t solaris-sparc32 10
screen -X -S builder -p 10 stuff "bash\n"
screen -X -S builder -p 10 stuff "ssh cross-solaris-sparc32\n"
screen -X -S builder -p 10 stuff "hostname\n"
screen -X -S builder -p 10 stuff "/crossnfs/_solaris_sparc32_tmp.sh\n"

screen -X -S builder screen -t solaris-x86 11
screen -X -S builder -p 11 stuff "bash\n"
screen -X -S builder -p 11 stuff "ssh cross-solaris-x86\n"
screen -X -S builder -p 11 stuff "hostname\n"
screen -X -S builder -p 11 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix solaris-x86-32bit \"solaris-x86-gcc no-asm\" \"-fPIE -m32\"\n"

screen -X -S builder screen -t solaris-x64 12
screen -X -S builder -p 12 stuff "bash\n"
screen -X -S builder -p 12 stuff "ssh cross-solaris-x64\n"
screen -X -S builder -p 12 stuff "hostname\n"
screen -X -S builder -p 12 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix solaris-x86-64bit solaris64-x86_64-gcc \"-fPIE -m64\"\n"

screen -X -S builder screen -t macos-ppc 13
screen -X -S builder -p 13 stuff "bash\n"
screen -X -S builder -p 13 stuff "ssh cross-macos-ppc\n"
screen -X -S builder -p 13 stuff "hostname\n"
screen -X -S builder -p 13 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix macos-ppc-32bit \"darwin-ppc-cc no-asm\" \"-fPIE -m32\" && /crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix macos-ppc-64bit \"darwin64-ppc-cc no-asm\" \"-fPIE -m64\"\n"

screen -X -S builder screen -t macos-x64 14
screen -X -S builder -p 14 stuff "bash\n"
screen -X -S builder -p 14 stuff "ssh cross-macos-x64\n"
screen -X -S builder -p 14 stuff "hostname\n"
screen -X -S builder -p 14 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix macos-x86-32bit \"darwin-i386-cc no-asm\" \"-fPIE -m32\" && /crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix macos-x86-64bit \"darwin64-x86_64-cc no-asm\" \"-fPIE -m64\"\n"

screen -X -S builder screen -t linux-arm64 15
screen -X -S builder -p 15 stuff "bash\n"
screen -X -S builder -p 15 stuff "ssh cross-linux-arm64\n"
screen -X -S builder -p 15 stuff "hostname\n"
screen -X -S builder -p 15 stuff "/crossnfs/SE-Build-crosslib_unix/scripts/task.sh SE-Build-crosslib_unix linux-arm64-64bit linux-aarch64 \"-fPIE -fno-builtin-ffs\"\n"
