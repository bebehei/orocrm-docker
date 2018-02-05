#!/bin/bash

su www-data -s /usr/bin/php -- "${INSTALLDIR}/src/app/console" "${@}"
