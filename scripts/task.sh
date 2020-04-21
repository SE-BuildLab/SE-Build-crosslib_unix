#!/bin/bash

cd /

set -e

if [ $# -le 2 ]; then
 echo Usage: build_all.sh build platform openssl_platform [options]
 exit 1
fi

build=$1
platform=$2
openssl_platform=$3

if [ ${platform} != "solaris-x86-32bit" ]; then
  if [[ $platform == *linux* ]]; then
    use_gnu="-D_GNU_SOURCE -D__USE_GNU"
  else
    use_gnu=" "
  fi
else
  use_gnu=" "
fi

options="$4 -D_FORTIFY_SOURCE=0 -D__USE_FORTIFY_LEVEL=0 $use_gnu"

if [ ${platform} = "macos-x86-64bit" ]; then
  export LIBRARY_PATH=/usr/lib_compile/gcc/i686-apple-darwin8/4.0.1/x86_64:/usr/lib_compile/gcc/i686-apple-darwin8/4.0.1:/usr/lib_compile
fi

export PATH=/usr/local/perl-5.10/bin:$PATH


# SKIP begin !!
#if false; then
## SKIP to HERE!!
#fi


# Initialize
echo --- Initialize - $build - $platform ---

cd ~
rm -fr ~/build-$platform/
mkdir -p ~/build-$platform/
cp /crossnfs/$build/src/*.tar.gz ~/build-$platform/
cp /crossnfs/$build/src/*.zip ~/build-$platform/

cd ~/build-$platform/

tar xzf libedit*.tar.gz
tar xzf libiconv*.tar.gz
tar xzf ncurses*.tar.gz
tar xzf openssl*.tar.gz
tar xzf zlib*.tar.gz
tar xzf libpcap*.tar.gz

mv `find . -maxdepth 1 -type d -name libedit\*` libedit
mv `find . -maxdepth 1 -type d -name libiconv\*` libiconv
mv `find . -maxdepth 1 -type d -name ncurses\*` ncurses
mv `find . -maxdepth 1 -type d -name openssl\*` openssl
mv `find . -maxdepth 1 -type d -name zlib\*` zlib
mv `find . -maxdepth 1 -type d -name libpcap\*` libpcap

mkdir -p /crossnfs/$build/output/$platform/

# OpenSSL
echo --- OpenSSL - $build - $platform ---

cd ~/build-$platform/openssl/

./Configure -D__NO_CTYPE $use_gnu threads no-hw no-engine no-shared no-dso enable-weak-ssl-ciphers enable-ssl3 enable-ssl3-method no-async $openssl_platform

perl -i.bak -p -e "s/-O3/-O2 $options/g" Makefile
perl -i.bak -p -e "s/INT_MAX/2147483647/g" ssl/s3_pkt.c

if [ ${platform} = "linux-ppc-32bit" ]; then
  perl -i.bak -p -e "s/    int a0, a1, a2, a3;/    int a0, a1, a2, a3; return 0;/g" crypto/x509v3/v3_utl.c
fi

if [ ${platform} = "linux-mipsel-32bit" ]; then
  perl -i.bak -p -e "s/    int a0, a1, a2, a3;/    int a0, a1, a2, a3; return 0;/g" crypto/x509v3/v3_utl.c
fi

cat <<\EOF > crypto/include/internal/dso_conf.h
#ifndef HEADER_DSO_CONF_H
# define HEADER_DSO_CONF_H
# define DSO_NONE
#endif
EOF

cp crypto/include/internal/dso_conf.h crypto/include/internal/dso_conf.h.in

rm -f libcrypto.a libssl.a

make || true

cp libcrypto.a /crossnfs/$build/output/$platform/
cp libssl.a /crossnfs/$build/output/$platform/

#echo OpenSSL TMP OK!
#exit 0

# zlib
echo --- zlib - $build - $platform ---

cd ~/build-$platform/zlib/

./configure

perl -i.bak -p -e "s/CFLAGS=-O3/CFLAGS=-O2 $options/g" Makefile
perl -i.bak -p -e "s/SFLAGS=-O3/SFLAGS=-O2 $options/g" Makefile

rm -f libz.a

make || true

cp libz.a /crossnfs/$build/output/$platform/


# iconv
echo --- iconv - $build - $platform ---

cd ~/build-$platform/libiconv/

if [ ${platform} = "macos-x86-64bit" ]; then
  perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./configure
  perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./libcharset/configure
  perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./preload/configure
  ./configure --enable-static=yes --enable-shared=no --build=i686-apple-darwin8 --host=x86_64-apple-darwin8 CC="/usr/bin/gcc -m64"
elif [ ${platform} = "linux-arm64-64bit" ]; then
  ./configure --enable-static=yes --enable-shared=no --build=aarch64-unknown-linux-gnu --host=aarch64-unknown-linux-gnu
else
  ./configure --enable-static=yes --enable-shared=no
fi

cd ~/build-$platform/libiconv/

perl -i.bak -p -e "s/CFLAGS = -g -O2/CFLAGS = -O2 $options/g" lib/Makefile
perl -i.bak -p -e "s/CFLAGS = -g -O2/CFLAGS = -O2 $options/g" libcharset/lib/Makefile

rm -f libcharset/lib/.libs/libcharset.a
rm -f lib/.libs/libiconv.a

make || true

cp libcharset/lib/.libs/libcharset.a /crossnfs/$build/output/$platform/
cp lib/.libs/libiconv.a /crossnfs/$build/output/$platform/


# ncurses
echo --- ncurses - $build - $platform ---

cd ~/build-$platform/ncurses/

if [ ${platform} = "macos-x86-64bit" ]; then
  perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./configure
  ./configure --enable-static=yes --enable-shared=no --without-gpm --build=i686-apple-darwin8 --host=x86_64-apple-darwin8 CC="/usr/bin/gcc -m64"
elif [ ${platform} = "linux-arm64-64bit" ]; then
  ./configure --enable-static=yes --enable-shared=no --without-gpm --build=aarch64-unknown-linux-gnu --host=aarch64-unknown-linux-gnu
else
  ./configure --enable-static=yes --enable-shared=no --without-gpm
fi

perl -i.bak -p -e "s/CFLAGS\t\t= -O2/CFLAGS\t\t= -O2 $options/g" ncurses/Makefile
perl -i.bak -p -e "s/CPPFLAGS\t= -DHAVE_CONFIG_H/CPPFLAGS\t= -DHAVE_CONFIG_H -D__NO_CTYPE/g" ncurses/Makefile

rm -f lib/libncurses.a

make || true

if [ ${platform} = "macos-x86-64bit" ]; then
  echo ncurses - macos-x86-64bit special
  echo special OK.
  cd ~/build-$platform/ncurses/ncurses/
  (export LIBRARY_PATH=/usr/lib/gcc/i686-apple-darwin8/4.0.1:/usr/lib && gcc -o make_hash -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include   -DMAIN_PROGRAM ./tinfo/comp_hash.c)
  make || true
  (export LIBRARY_PATH=/usr/lib/gcc/i686-apple-darwin8/4.0.1:/usr/lib && gcc -o make_keys -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include   ./tinfo/make_keys.c)
  echo special OK.
  cd ~/build-$platform/ncurses/
  make || true
fi

if [ ${platform} = "macos-ppc-64bit" ]; then
  echo ncurses - macos-ppc-64bit special
  cd ~/build-$platform/ncurses/ncurses/
  gcc -o make_hash -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include -DHAVE_CONFIG_H -D__NO_CTYPE -I../ncurses -I. -I. -I../include  -U_XOPEN_SOURCE -D_XOPEN_SOURCE=500 -DSIGWINCH=28 -DNDEBUG -I/usr/local/include/ncurses -O2 -fPIE --param max-inline-insns-single=1200  -no-cpp-precomp -DMAIN_PROGRAM ./tinfo/comp_hash.c -Wl,-search_paths_first
  make || true
  gcc -o make_keys -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include -DHAVE_CONFIG_H -D__NO_CTYPE -I../ncurses -I. -I. -I../include  -U_XOPEN_SOURCE -D_XOPEN_SOURCE=500 -DSIGWINCH=28 -DNDEBUG -I/usr/local/include/ncurses -O2 -fPIE --param max-inline-insns-single=1200  -no-cpp-precomp ./tinfo/make_keys.c -Wl,-search_paths_first
  echo special OK.
  cd ~/build-$platform/ncurses/
  make || true
fi

if [ ${platform} = "solaris-sparc-64bit" ]; then
  echo ncurses - solaris-sparc-64bit special
  cd ~/build-$platform/ncurses/ncurses/
  gcc -o make_hash -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include -DHAVE_CONFIG_H -D__NO_CTYPE -I../ncurses -I. -I. -I../include  -D__EXTENSIONS__ -D_FILE_OFFSET_BITS=64  -DNDEBUG -I/usr/local/include/ncurses -O2 -fPIE --param max-inline-insns-single=1200 -DMAIN_PROGRAM ./tinfo/comp_hash.c
  make || true
  gcc -o make_keys -DHAVE_CONFIG_H -I../ncurses -I. -I./../include -I../include -DHAVE_CONFIG_H -D__NO_CTYPE -I../ncurses -I. -I. -I../include  -D__EXTENSIONS__ -D_FILE_OFFSET_BITS=64  -DNDEBUG -I/usr/local/include/ncurses -O2 -fPIE --param max-inline-insns-single=1200 ./tinfo/make_keys.c 
  echo special OK.
  cd ~/build-$platform/ncurses/
  make || true
fi

cp lib/libncurses.a /crossnfs/$build/output/$platform/

mkdir -p ~/tmp-build-lib/
cp lib/libncurses.a ~/tmp-build-lib/libncurses.a
cp lib/libncurses.a ~/tmp-build-lib/libncurses2.a



# libedit
echo --- libedit - $build - $platform ---

cd ~/build-$platform/libedit/

if [ ${platform} = "macos-x86-64bit" ]; then
  perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./configure
  perl -i.bak -p -e "s/-lncurses/-lncurses2/g" ./configure
  ./configure --enable-static=yes --enable-shared=no --build=i686-apple-darwin8 --host=x86_64-apple-darwin8 CC="/usr/bin/gcc -m64 -L/Users/cross/tmp-build-lib"
elif [ ${platform} = "linux-sh4-32bit" ]; then
  rm -f ./configure
  wget http://uploader.sehosts.com/rpm/191015/configure
  chmod 777 ./configure
  perl -i.bak -p -e "s/-lncurses/-lncurses2/g" ./configure
  ./configure --enable-static=yes --enable-shared=no CC="/usr/bin/gcc -L/home/cross/tmp-build-lib"
elif [ ${platform} = "linux-arm64-64bit" ]; then
  ./configure --enable-static=yes --enable-shared=no --build=aarch64-unknown-linux-gnu --host=aarch64-unknown-linux-gnu
else
  ./configure --enable-static=yes --enable-shared=no
fi

perl -i.bak -p -e "s/CFLAGS = -g -O2/CFLAGS = -O2 $options/g" Makefile
perl -i.bak -p -e "s/CXXFLAGS = -g -O2/CXXFLAGS = -O2 $options/g" Makefile
perl -i.bak -p -e "s/DEFS = -DHAVE_CONFIG_H/DEFS = -DHAVE_CONFIG_H -D__NO_CTYPE/g" Makefile
perl -i.bak -p -e "s/CFLAGS = -g -O2/CFLAGS = -O2 $options/g" src/Makefile
perl -i.bak -p -e "s/CXXFLAGS = -g -O2/CXXFLAGS = -O2 $options/g" src/Makefile
perl -i.bak -p -e "s/DEFS = -DHAVE_CONFIG_H/DEFS = -DHAVE_CONFIG_H -D__NO_CTYPE/g" src/Makefile
perl -i.bak -p -e "s/LTCFLAGS=\"-g -O2\"/LTCFLAGS=\"-O2 $options\"/g" libtool
perl -i.bak -p -e "s/if \(i <= 0\) \{/if \(i <= 0\) \{ if \(0\) \{/g" src/term.c
perl -i.bak -p -e "s/Val\(T_co\) = 80;\t\/\* do a dumb terminal \*\//\} Val\(T_co\) = 80;/g" src/term.c
perl -i.bak -p -e "s/__weak_reference/__weak_reference_dummy/g" src/vi.c

perl -i.bak -p -e "s/assert\(c-- != 0\);/\/\/ assert\(c-- != 0\);/g" src/tty.c
perl -i.bak -p -e "s/assert\(c != -1\);/\/\/ assert\(c != -1\);/g" src/tty.c

rm -f src/.libs/libedit.a

make || true

cp src/.libs/libedit.a /crossnfs/$build/output/$platform/


# libpcap
if [[ $platform == *macos* ]]; then
  echo --- libpcap - $build - $platform ---

  cd ~/build-$platform/libpcap/

  if [ ${platform} = "macos-x86-64bit" ]; then
    perl -i.bak -p -e "s/cross_compiling=no/cross_compiling=yes/g" ./configure
    ./configure --build=i686-apple-darwin8 --host=x86_64-apple-darwin8 --with-pcap=bpf CC="/usr/bin/gcc -m64"
  else
    ./configure
  fi

  perl -i.bak -p -e "s/CFLAGS = -g -O2/CFLAGS = -O2 $options/g" Makefile

  rm -f libpcap.a

  make

  cp libpcap.a /crossnfs/$build/output/$platform/
fi

# Finished
sync
sync
sync

echo
echo --- Finished !!! - $build - $platform ---
echo


