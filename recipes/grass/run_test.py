#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import hashlib
import subprocess
import tempfile
import tarfile

import requests

GRASSBIN = 'grass78'
TEST_DATA_FILE = "nc_basic_spm_grass7.tar.gz"
TEST_DATA_URL = f"https://grass.osgeo.org/sampledata/north_carolina/{TEST_DATA_FILE}"
TEST_DATA_SHA256 = "6dd68818d9a6c181f16e712b68a22a73f38a4294283968c776e42fc33fe6697f"


def sha256(file_path):
    hash_sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()

def dl_data(data_file_name, data_url, data_hash):
    # dir_path = os.path.dirname(os.path.realpath(__file__))
    tempdir = tempfile.mkdtemp(prefix='grassdata')
    file_path = os.path.join(tempdir, data_file_name)

    assert os.path.isdir(tempdir)
    assert os.access(tempdir, os.W_OK)

    # Download
    with requests.get(data_url, stream=True) as response, open(file_path, 'wb') as f:
        response.raise_for_status()
        for chunk in response.iter_content(chunk_size=8192): 
            f.write(chunk)
    assert sha256(file_path) == data_hash
    # Extract file
    with tarfile.open(file_path) as tar:
        tar.extractall(tempdir)
    grassdata = tempdir
    location = os.listdir(tempdir)[0]
    return grassdata, location, 'PERMANENT'

def get_gisbase(grassbin):
    """query GRASS 7 itself for its GISBASE
    """
    startcmd = [grassbin, '--config', 'path']
    try:
        p = subprocess.Popen(startcmd, shell=False,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        stdout, stderr = p.communicate()
    except OSError as error:
        raise FileNotFoundError("Cannot find GRASS GIS binary"
                                " '{cmd}' {error}".format(cmd=startcmd[0], error=error))
    if p.returncode != 0:
        raise RuntimeError("Error while running GRASS GIS start-up script"
                           " '{cmd}': {error}".format(cmd=' '.join(startcmd), error=stderr))
    return stdout.strip().decode('utf-8')

def set_session(grassbin, gisdb, location, mapset):
    # query GRASS 7 itself for its GISBASE
    gisbase = get_gisbase(grassbin)
    # Set GISBASE environment variable
    os.environ['GISBASE'] = gisbase
    # define GRASS Python environment
    grass_python = os.path.join(gisbase, u"etc", u"python")
    sys.path.append(grass_python)
    # launch session
    import grass.script.setup as gsetup
    rcfile = gsetup.init(gisbase, gisdb, location, mapset)
    return rcfile

def test_region():
    reg = gscript.read_command('g.region', flags='p')
    print(reg)


gisdb, location, mapset = dl_data(TEST_DATA_FILE, TEST_DATA_URL, TEST_DATA_SHA256)
rcfile = set_session(GRASSBIN, gisdb, location, mapset)
print(rcfile)
import grass.script as gscript
# test_region()
