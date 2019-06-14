#!/bin/bash

CPU_CORE=$( lscpu -pCPU | grep -v "#" | wc -l )

SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "${SOURCE_DIR}" == "${PWD}" ]; then
   BUILD_DIR="${PWD}/build"
else
   BUILD_DIR="${PWD}"
fi

if (mount | grep "/tmp " | grep --quiet noexec); then
     mkdir -p $SOURCE_DIR/tmp
     TEMP_DIR="${SOURCE_DIR}/tmp"
     rm -rf $SOURCE_DIR/tmp/*
else # noexec wasn't found
     TEMP_DIR="/tmp"
fi

BOOST_ROOT="${SOURCE_DIR}/libraries/boost"

if [ -d "${SOURCE_DIR}/libraries/boost_1_70_0" ]; then
   if ! mv "${SOURCE_DIR}/libraries/boost_1_70_0" "$BOOST_ROOT"
   then
      printf "\\n\\tUnable to move directory %s/libraries/boost_1_70_0 to %s.\\n" "${SOURCE_DIR}" "${BOOST_ROOT}"
      printf "\\n\\tExiting now.\\n"
      exit 1
   fi
   if [ -d "$BUILD_DIR" ]; then
      if ! rm -rf "$BUILD_DIR"
      then
      printf "\\tUnable to remove directory %s. Please remove this directory and run this script %s again. 0\\n" "$BUILD_DIR" "${BASH_SOURCE[0]}"
      printf "\\tExiting now.\\n\\n"
      exit 1;
      fi
   fi
fi

printf "\\n\\tChecking boost library installation.\\n"
BVERSION=$( grep BOOST_LIB_VERSION "${BOOST_ROOT}/include/boost/version.hpp" 2>/dev/null \
| tail -1 | tr -s ' ' | cut -d\  -f3 | sed 's/[^0-9\._]//gI')
if [ "${BVERSION}" != "1_70" ]; then
   printf "\\tRemoving existing boost libraries in %s/libraries/boost* .\\n" "${SOURCE_DIR}"
   if ! rm -rf "${SOURCE_DIR}"/libraries/boost*
   then
      printf "\\n\\tUnable to remove deprecated boost libraries at this time.\\n"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1;
   fi
   printf "\\tInstalling boost libraries.\\n"
   if ! cd "${TEMP_DIR}"
   then
      printf "\\n\\tUnable to enter directory %s.\\n" "${TEMP_DIR}"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1;
   fi
   STATUS=$(curl -LO -w '%{http_code}' --connect-timeout 30 https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.bz2)
   if [ "${STATUS}" -ne 200 ]; then
      printf "\\tUnable to download Boost libraries at this time.\\n"
      printf "\\tExiting now.\\n\\n"
      exit 1;
   fi
   if ! tar xf "${TEMP_DIR}/boost_1_70_0.tar.bz2"
   then
      printf "\\n\\tUnable to unarchive file %s/boost_1_70_0.tar.bz2.\\n" "${TEMP_DIR}"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1;
   fi
   if ! rm -f "${TEMP_DIR}/boost_1_70_0.tar.bz2"
   then
      printf "\\n\\tUnable to remove file %s/boost_1_70_0.tar.bz2.\\n" "${TEMP_DIR}"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1;
   fi
   if ! cd "${TEMP_DIR}/boost_1_70_0/"
   then
      printf "\\n\\tUnable to enter directory %s/boost_1_70_0.\\n" "${TEMP_DIR}"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1;
   fi
   if ! ./bootstrap.sh "--prefix=$BOOST_ROOT"
   then
      printf "\\n\\tInstallation of boost libraries failed. 0\\n"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1
   fi
   if ! ./b2 -j"${CPU_CORE}" install
   then
      printf "\\n\\tInstallation of boost libraries failed. 1\\n"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1
   fi
   if ! rm -rf "${TEMP_DIR}"/boost_1_70_0
   then
      printf "\\n\\tUnable to remove %s/boost_1_70_0.\\n" "${TEMP_DIR}"
      printf "\\n\\tExiting now.\\n\\n"
      exit 1
   fi
   if [ -d "$BUILD_DIR" ]; then
      if ! rm -rf "$BUILD_DIR"
      then
      printf "\\tUnable to remove directory %s. Please remove this directory and run this script %s again. 0\\n" "$BUILD_DIR" "${BASH_SOURCE[0]}"
      printf "\\tExiting now.\\n\\n"
      exit 1;
      fi
   fi
   printf "\\tBoost successfully installed @ %s.\\n" "${BOOST_ROOT}"
else
   printf "\\tBoost found at %s.\\n" "${BOOST_ROOT}"
fi

if [ ! -d "$BUILD_DIR" ]; then
   mkdir "$BUILD_DIR"
fi

cd $BUILD_DIR
cmake ..
make -j"${CPU_CORE}"
