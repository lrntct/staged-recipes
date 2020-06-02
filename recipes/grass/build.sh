#! /bin/bash

# if [[ $target_platform =~ linux.* ]]; then
#     export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/lib"
# fi

# export PREFIX=$(python -c 'import sys; print sys.prefix')
# export PATH=$PREFIX/bin:/usr/bin:/bin:/usr/sbin:/etc:/usr/lib

if [ $(uname) == Darwin ]; then
  export GRASS_PYTHON=$(which pythonw)
else
  export GRASS_PYTHON=$(which python)
  export LD_LIBRARY_PATH=$PREFIX/lib
fi

CONFIGURE_FLAGS="\
  --prefix=$PREFIX \
  --with-freetype \
  --with-freetype-includes=$PREFIX/include/freetype2 \
  --with-freetype-libs=$PREFIX/lib \
  --with-gdal
  --with-proj
  --with-geos
  --with-blas
  --with-pdal
  --without-postgres \
  --without-mysql \
  --with-sqlite \
  --with-fftw
  --with-cxx \
  --with-cairo \
  --without-readline \
  --without-opengl \
  --enable-64bit \
  --enable-zlib \
  --enable-zstd \
  --with-python3=$GRASS_PYTHON \
"

# CONFIGURE_FLAGS="\
#   --prefix=$PREFIX \
#   --with-freetype \
#   --with-freetype-includes=$PREFIX/include/freetype2 \
#   --with-freetype-libs=$PREFIX/lib \
#   --with-gdal=$PREFIX/bin/gdal-config \
#   --with-gdal-libs=$PREFIX/lib \
#   --with-proj=$PREFIX/bin/proj \
#   --with-proj-includes=$PREFIX/include/ \
#   --with-proj-libs=$PREFIX/lib \
#   --with-proj-share=$PREFIX/share/proj \
#   --with-geos=$PREFIX/bin/geos-config \
#   --with-jpeg-includes=$PREFIX/include \
#   --with-jpeg-libs=/$PREFIX/lib \
#   --with-png-includes=$PREFIX/include \
#   --with-png-libs=$PREFIX/lib \
#   --with-tiff-includes=$PREFIX/include \
#   --with-tiff-libs=$PREFIX/lib \
#   --without-postgres \
#   --without-mysql \
#   --with-sqlite \
#   --with-sqlite-libs=$PREFIX/lib \
#   --with-sqlite-includes=$PREFIX/include \
#   --with-fftw-includes=$PREFIX/include \
#   --with-fftw-libs=$PREFIX/lib \
#   --with-cxx \
#   --with-cairo \
#   --with-cairo-includes=$PREFIX/include/cairo \
#   --with-cairo-libs=$PREFIX/lib \
#   --with-cairo-ldflags="-lcairo" \
#   --without-readline \
#   --enable-64bit \
#   --with-libs=$PREFIX/lib \
#   --with-includes=$PREFIX/include \
#   --with-python3=$GRASS_PYTHON \
# "

if [ $(uname) == Darwin ]; then
  CONFIGURE_FLAGS="\
    $CONFIGURE_FLAGS \
    --with-opengl=aqua \
    "
#    --enable-macosx-app
#    --with-opencl
#  --with-macosx-sdk=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
fi

./configure $CONFIGURE_FLAGS
make -j4 > log_make.txt
make -j4 # GDAL_DYNAMIC= > out.txt 2>&1 || (tail -400 out.txt && echo "ERROR in make step" && exit -1)
make -j4 install

# ACTIVATE_DIR=$PREFIX/etc/conda/activate.d
# DEACTIVATE_DIR=$PREFIX/etc/conda/deactivate.d
# mkdir -p $ACTIVATE_DIR
# mkdir -p $DEACTIVATE_DIR
# cp $RECIPE_DIR/scripts/activate.sh $ACTIVATE_DIR/grass-activate.sh
# cp $RECIPE_DIR/scripts/deactivate.sh $DEACTIVATE_DIR/grass-deactivate.sh
