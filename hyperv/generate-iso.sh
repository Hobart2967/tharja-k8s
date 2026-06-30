#!/bin/sh
(cd src && genisoimage \
  -output ../seed.iso \
  -volid CIDATA \
  -joliet \
  -rock \
  user-data meta-data)