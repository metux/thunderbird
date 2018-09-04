#!/bin/sh
#
# create-lightning-l10n-tarball.sh
# Porpose:
# Create an upstream tarball from the Lightning xpi language packs.
# Current stable and beta version can be found on
#    https://addons.mozilla.org/de/thunderbird/addon/lightning/versions/

EXIT_SUCCESS=0
EXIT_FAILURE=1

# Initialize our own variables:
VERBOSE=0
FILE=""
ARG_COUNT=0
LANG_COUNT=0
CURDIR_FULL=`pwd`
CURDIR=$(basename `pwd`)
MOZILLA_CDN_PROTO="https://"
MOZILLA_CDN_BASE="download-origin.cdn.mozilla.net/pub/thunderbird"

# default package name
XPI=lightning.xpi
BASE_PKG="lightning-l10n"

# local functions
usage () {
cat << EOF

Usage: ${0##*/} [-h|-vd] [-e BETA_VER] VERSION

    -h         display this help and exit
    -v         verbose mode, increase the output messages
    -d         download given [VERSION]
    -e         download [BETA_VER] from the beta versions
                 (Used in combination with '-d' to get beta marked upstream
                  versions.)

    [BETA_VER] given beta version of the upstream TB version, it will be re
                 calculated into the correct Lightning version

    [VERSION]  given version in Debian format for downloading and/or creating
                 the *.orig.tar.xz

Examples:
  ${0##*/} -d 45.1
    Download version '45.1' of the Lightning l10n packages from Mozilla and creates
    a file 'thunderbird-45.1.orig-lightning-l10n.tar.xz' that can be imported with
    'git-import-orig'.

  ${0##*/} -de 45.1b1 45.1~b1
    Download the beta version '45.1b1' of the Lightning l10n packages from Mozilla
    and created a file 'thunderbird-45.1~b1.orig-lightning-l10n.tar.xz'. This file can be
    automatically imported with 'git-import-orig'.

EOF
}

debug () {
if [ "${VERBOSE}" = "1" ]; then
    echo "DEBUG -> $1"
fi
}

fail () {
    echo $*
    exit ${EXIT_FAILURE}
}

########################
# We are starting here #
########################

# check for wget, curl and python2
test -f /usr/bin/wget || fail "wget is missing, please install first!"
test -f /usr/bin/curl || fail "curl is missing, please install first!"
test -f /usr/bin/python || fail "python2 is missing, please install first!"

# check if we are inside icedove/ and have a git environment
if [ "${CURDIR}" != "thunderbird" ]; then
    echo "Not in thunderbird/.."
    exit ${EXIT_FAILURE}
else
    if [ ! -d .git ]; then
        echo "no directory .git/ found! You are in the correct directory?"
        exit ${EXIT_FAILURE}
    fi
fi

# we have no options found?
if [ "$#" -le 1 ]; then
    echo "You need at least one option!" >&2
    echo
    usage ${EXIT_FAILURE}
fi

OPTIND=1 # Reset is necessary if getopts was used previously in the script. It is a good idea to make this local in a function.
while getopts "hvde:" opt; do
    case "${opt}" in
        h)  HELP=1
            usage
            exit
            ;;
        v)  echo "[[ ... using verbose mode ... ]]"
            VERBOSE=1
            debug "found option '-v'"
            ;;
        d)  DOWNLOAD=yes
            debug "found option '-d'"
            ;;
        e)  BETA_VER=${OPTARG}
            EXPERIMENTAL=1
            debug "found option '-e' with given BETA_VER: ${BETA_VER}"
            ;;
        :)  "Option -${OPTARG} requires an argument." >&2
            exit 1
            ;;
        '?')
            usage >&2
            exit 1
            ;;
    esac
done

# shift found options
shift $(( OPTIND - 1 ))

# looping the arguments, we should have at least only one without an option!
for ARG; do
    ARG_COUNT=`expr ${ARG_COUNT} + 1`
    debug "given argument: ${ARG}"
    debug "ARG_COUNT = ${ARG_COUNT}"
done
if [ "${ARG_COUNT}" = "0" ]; then
    echo "missing argument for VERSION!"
    exit ${EXIT_FAILURE}
elif [ "${ARG_COUNT}" != "1" ]; then
    echo "more than one argument for VERSION given!"
    exit ${EXIT_FAILURE}
fi

# o.k. the last argument should be the version
VERSION=${ARG}
TB_VERSION=${VERSION}

debug "Download xpi: ........ ${DOWNLOAD:-off}"
if [ "${BETA_VER}" != "" ]; then
    debug "Upstream TB version: . ${BETA_VER}"
    TB_VERSION=${BETA_VER}
fi
LN_VERSION=`echo $(python comm/calendar/lightning/build/makeversion.py ${TB_VERSION})`
debug "Debian version: ...... ${VERSION}"
debug "Lightning version: ... ${LN_VERSION}"

# creating temporary directories inside /tmp
# UNPACKDIR -> the directory there the original '${lightning-l10n}.xpi' or the single
#              'lightning-${LN_VERSION}.$LANG.linux-i686.xpi' will be extracted, it
#              contains the complete content of the lightning.xpi
# ORIGDIR   -> the directory for the plain needed content of the ${LANG},
#              will be used for the debian.orig.tar.xz

export TMPDIR="${HOME}/tmp/tb-lightning-tmp"
       UNPACKDIR="${TMPDIR}/${TB_VERSION}/unpack/"
       TBARCHIVEDIR="${TMPDIR}"
       ORIGDIR="${TMPDIR}${BASE_PKG}-${VERSION}/${BASE_PKG}"
echo ${TMPDIR}
# download Thunderbird precompiled archives from the CDN of Mozilla
if [ -n "${DOWNLOAD}" ]; then
    rm -f ${XPI}
    if [ -n "${EXPERIMENTAL}" ]; then
        debug "${MOZILLA_CDN_PROTO}${MOZILLA_CDN_BASE}/releases/${TB_VERSION}/linux-i686"
        debug "creating ${UNPACKDIR}"
        mkdir -p ${UNPACKDIR}lightning-l10n
        debug "going downloading Thunderbird archives from ${MOZILLA_CDN_PROTO}${MOZILLA_CDN_BASE}/releases/${TB_VERSION}/linux-i686/"
        cd ${TMPDIR}
        # going to download the files
        LIST=`curl -L --silent "${MOZILLA_CDN_PROTO}${MOZILLA_CDN_BASE}/releases/${TB_VERSION}/linux-i686/" | grep "<td><a href=" | grep "linux-i686" | awk '{print $2}' | grep -v xpi | tr '"' ' ' | awk '{print $2}'`
        for i in ${LIST}; do
            LANG=`echo $i | cut -d '/' -f7`
            ARCHIVEDIR="${TBARCHIVEDIR}/${LANG}"
            echo "download https://download-origin.cdn.mozilla.net${i}thunderbird-${TB_VERSION}.tar.bz2 into ${ARCHIVEDIR}"
            wget -N -P ${ARCHIVEDIR} https://download-origin.cdn.mozilla.net${i}thunderbird-${TB_VERSION}.tar.bz2

            UNPACKSTEP1="${UNPACKDIR}/${LANG}-step1"
            debug "creating ${UNPACKSTEP1}"
            mkdir ${UNPACKSTEP1}
            debug "unpack ${LANG}/thunderbird-${TB_VERSION}.tar.bz2 into ${UNPACKSTEP1}"
            tar -xjf ${LANG}/thunderbird-${TB_VERSION}.tar.bz2 -C ${UNPACKSTEP1}

            UNPACKSTEP2="${UNPACKDIR}/${LANG}-step2"
            debug "creating ${UNPACKSTEP2}"
            mkdir "${UNPACKSTEP2}"
            unzip -q -o -d "${UNPACKSTEP2}" "${UNPACKSTEP1}/thunderbird/distribution/extensions/{e2fda1a4-762b-4020-b5ad-a41df1933103}.xpi"
            debug "creating ${UNPACKDIR}/lightning-l10n/${LANG}/chrome"
            mkdir -p ${UNPACKDIR}lightning-l10n/${LANG}/chrome
            cp -a ${UNPACKSTEP2}/chrome/calendar-${LANG} ${UNPACKSTEP2}/chrome/lightning-${LANG}  ${UNPACKDIR}/lightning-l10n/${LANG}/chrome
        done
    fi
else
    if [ "${FILE}" != "" ]; then
        # we should have a local *.xpi file
        XPI=${FILE}
    fi
fi

debug "creating folder '${ORIGDIR}'"
mkdir -p ${ORIGDIR}

if [ "$EXPERIMENTAL" != "1" ]; then
    # don't try to do anything if we have download beta versions'
    # FIXME --> this wont with version 4.0 or greater <-- needs to be fixed
    # with the release of 4.0
    unzip -q -d ${UNPACKDIR} ${XPI} || fail "Oops! Failed to unzip ${XPI}"
fi

# getting the versions
TB_VER=$(grep -A2 '{3550f703-e582-4d05-9a08-453d09bdfdc6}' ${UNPACKDIR}en-US-step2/install.rdf)
if [ "$?" != "0" ]; then
    debug "error"
    debug "UNPACKDIR: ${UNPACKDIR}"
    exit 1
fi

# shipped with lightning already, removing the folder 'en-US'
debug "removing language 'en-US' ${UNPACKDIR}lightning-l10n/en-US"
rm -rf ${UNPACKDIR}lightning-l10n/en-US*
mv ${UNPACKDIR}lightning-l10n/* ${ORIGDIR}

debug "creating 'thunderbird_${VERSION}.orig-${BASE_PKG}.tar.xz'"
TARBALL="../thunderbird_${VERSION}.orig-${BASE_PKG}.tar.xz"
cd ${ORIGDIR}/..
tar Jcf ${TARBALL} ${BASE_PKG}
TARBALL=$(readlink -f ${TARBALL})

echo
echo "Lightning version information"
echo ${TB_VER}

# counting languages
LANG_COUNT=`ls -l ${ORIGDIR} | wc -l`

# moving *-orig-*.tar.xz back
cd ${CURDIR_FULL}
mv $TARBALL ../
TARBALL=$(readlink -f ../thunderbird_${VERSION}.orig-${BASE_PKG}.tar.xz)
echo
echo "Tarball created in:"
echo "  -> ${TARBALL} <-"
echo "     (language count: ${LANG_COUNT})"

# always remove temporary things
debug "cleanup ..."
rm -rf ${TMPDIR}/*

echo "done."

exit $EXIT_SUCCESS
