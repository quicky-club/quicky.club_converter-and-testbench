#!/bin/sh
# shellcheck shell=dash
#
# TODO: https://chromium.googlesource.com/codecs/libwebp2/
# TODO: https://bellard.org/bpg/


FILE_INPUT="$1"
MYSETTINGS="$2"	# e.g. avif-all-avifenc-q45 or 'all'
		#                       ^^^ quality=45
		#               ^^^^^^^ encoder
		#           ^^^ color-reduction
		#      ^^^^ format

REPRODUCER="$0 $*"

log() { >&2 printf '%s\n' "$1"; }
check() { command -v "$1" >/dev/null && printf '\n%s\n' "# command '$1'" && return 0; log "[ERROR] missing '$1', see: $2" && exit 1; }

ba() { false; }
ss() { false; }

while [ -n "$1" ]; do {
  case "$1" in
    '--butteraugli'|'-ba') BUTTERAUGLI=true && ba() { true; } ;;
    '--ssimulacra2'|'-ss') SSIMULACRA2=true && ss() { true; } ;;
    '--parallel'|'-p') PARALLEL="$2" ;;
    '--upload'|'-u') UPLOAD=true ;;
    '--dir'|'-d') TARGET_DIR="$2" && test -d "$TARGET_DIR" && mkdir -p "$TARGET_DIR" ;;
  esac; shift
} done

if [ -f "$FILE_INPUT" ]; then
	MIME="$( file -ib "$FILE_INPUT" )"
	case "$MIME" in
		image/png*) ;;
		*)
			log "[INFO] inputfile must be PNG, but is '$MIME', will try to convert it"
			TEMP_PNG="$( mktemp -u ).png" || exit 1
			convert "$FILE_INPUT" "$TEMP_PNG" || exit 1
		;;
	esac
elif case "$FILE_INPUT" in https://*) true ;; *) false ;; esac; then
	JSON="$( curl --silent --fail "$FILE_INPUT" )" || { log "[ERROR:$?] downloading '$FILE_INPUT'" && exit 1; }
	# e.g. https://show.quicky.club/results/1234/76/2f/1b/950f1dae9bcbd4efd6453fc98e31dacfd164d7a1be17c1aa05438c85ec-7229675.json
	#   => https://show.quicky.club/results/1234/image-hcoTgAmLF3RK-560px.html
	BASEURL="$( echo "$JSON" | jq -r '.data.url' )" || { log "[ERROR:$?] jq extract '.data.url'" && exit 1; }
	log "not implemented yet: $BASEURL | BUTTERAUGLI=$BUTTERAUGLI | SSIMULACRA2=$SSIMULACRA2 | UPLOAD=$UPLOAD"
	exit 1
else
	log "[ERROR] invalid input: '$FILE_INPUT' - must be a PNG file or URL to JSON"
	FILE_INPUT=
fi

[ -z "$MYSETTINGS" ] || [ -z "$FILE_INPUT" ] && {
	echo "Usage: $0 <file-or-URL> <settings> [--butteraugli] [--ssimulacra2] [--parallel 8]"
	echo
	echo " e.g.: $0 test.png all"
	echo "       $0 test.png avif-all-avifenc-q45"
	echo "       $0 test.png jpeg-all-cjpegli"
	echo "       $0 http://server/image.png all"
	exit 1
}

[ -z "$PARALLEL" ] && PARALLEL="$( nproc )" && test "$PARALLEL" -gt 1 && PARALLEL=$(( PARALLEL - 1 ))
test -z "$TARGET_DIR" && {
	TARGET_DIR="$( mktemp -d --suffix="-converted" )" || exit 3
}
I=0
TS="$( date +%s )"
export I TARGET_DIR


{
check jq          https://github.com/jqlang/jq                 && jq --version
check awk         https://www.gnu.org/software/gawk/manual/html_node/Language-History.html && awk --version 2>&1 | grep -v version | head -n1
check stat        https://www.gnu.org/software/coreutils/      && stat --version | head -n1
check find        https://www.gnu.org/software/coreutils/      && find . --version | head -n1
check file        https://github.com/file/file                 && file --version | head -n1
check nproc       https://www.gnu.org/software/coreutils/      && nproc --version | head -n1
check guetzli     https://github.com/google/guetzli.git        && echo "guetzli v1.0.1 (a0f47a2)"
check gnuplot     http://www.gnuplot.info/                     && gnuplot --version
check avifenc     https://github.com/AOMediaCodec/libavif      && avifenc --version | head -n1
check avifdec     https://github.com/AOMediaCodec/libavif      && avifdec --version | head -n1
check mozjpeg     https://github.com/mozilla/mozjpeg.git       && mozjpeg -version 2>&1
check cjpegli     https://github.com/libjxl/libjxl
check cjxl        https://github.com/libjxl/libjxl
check djxl        https://github.com/libjxl/libjxl
check cwebp       https://github.com/webmproject/libwebp       && cwebp -version | head -n1
check dwebp       https://github.com/webmproject/libwebp       && dwebp -version | head -n1
check pngquant    https://github.com/kornelski/pngquant        && pngquant --version
check zopflipng   https://github.com/google/zopfli
check butteraugli https://github.com/google/butteraugli.git
check butteraujxl https://github.com/libjxl/libjxl
check ssimulacra2 https://github.com/cloudinary/ssimulacra2.git
check fssimu2     https://github.com/gianni-rosato/fssimu2     && fssimu2 --version 2>&1 | head -n1
check curl        https://github.com/curl/curl                 && curl --version | head -n1
# TODO: imagemagick convert for jpeg
} >"$TARGET_DIR/stats-system.txt"


EXTENSION="$( echo "$MIME" | cut -d';' -f1 | cut -d'/' -f2 )"	# e.g. png
cp -v "$FILE_INPUT" "$TARGET_DIR/inputfile.$EXTENSION"
SIZE_ORIGINAL="$( stat -c %s "$FILE_INPUT" )"
[ -f "$TEMP_PNG" ] && FILE_INPUT="$TEMP_PNG"


do_jpeg_guetzli()
{
  guetzli --quality "$QUALITY" "$FILE_INPUT" "$FILE_OUTPUT" && {
    time_get && STATS="in $MILLISEC ms"

    do_butteraugli "$FILE_INPUT" "$FILE_OUTPUT"
    do_ssimulacra2 "$FILE_INPUT" "$FILE_OUTPUT"
  }
}

do_avif_avifenc()
{
  avifenc --jobs 1 --speed 6 --qcolor "$QUALITY" --qalpha "$QUALITY" --output "$FILE_OUTPUT" -- "$FILE_INPUT" >/dev/null && {
    time_get && STATS="in $MILLISEC ms"

    RESULT_PNG="$FILE_OUTPUT.$SETTINGS.png"
    ba || ss && avifdec --jobs 1 "$FILE_OUTPUT" "$RESULT_PNG" >/dev/null

    do_butteraugli "$FILE_INPUT" "$RESULT_PNG"
    do_ssimulacra2 "$FILE_INPUT" "$RESULT_PNG"
    rm -f "$RESULT_PNG"
  }
}

do_jpeg_mozjpeg()
{
  mozcjpeg -quality "$QUALITY" <"$FILE_INPUT" >"$FILE_OUTPUT" && {
    time_get && STATS="in $MILLISEC ms"

    do_butteraugli "$FILE_INPUT" "$FILE_OUTPUT"
    do_ssimulacra2 "$FILE_INPUT" "$FILE_OUTPUT"
  }
}

do_jpeg_cjpegli()
{
  cjpegli -q "$QUALITY" -p 2 --chroma_subsampling=420 -- "$FILE_INPUT" "$FILE_OUTPUT" && {
    time_get && STATS="in $MILLISEC ms"

    do_butteraugli "$FILE_INPUT" "$FILE_OUTPUT"
    do_ssimulacra2 "$FILE_INPUT" "$FILE_OUTPUT"
  }
}

do_jxl_cjxl()
{
  cjxl "$FILE_INPUT" "$FILE_OUTPUT" -q "$QUALITY" -e 10 --quiet && {
    time_get && STATS="in $MILLISEC ms"

    # when changing the e-parameter, we also change the image, e.g.: "-e 7" vs. "-e 10":
    # jxl-all-cjxl-q30 filesize: 33517 bytes in  7630 ms butteraugli:  8.70 in 173440 ms butteraujxl: 7.84 in 11750 ms ssimulacra2: 64.16 in 1730 ms
    # jxl-all-cjxl-q30 filesize: 30566 bytes in 36940 ms butteraugli: 10.89 in 178300 ms butteraujxl: 9.46 in 10820 ms ssimulacra2: 62.31 in 6160 ms

    RESULT_PNG="$FILE_OUTPUT.$SETTINGS.png"
    ba || ss && djxl "$FILE_OUTPUT" "$RESULT_PNG" --quiet

    do_butteraugli "$FILE_INPUT" "$RESULT_PNG"
    do_ssimulacra2 "$FILE_INPUT" "$RESULT_PNG"
    rm -f "$RESULT_PNG"
  }
}

do_webp_cwebp()
{
  cwebp -short -o "$FILE_OUTPUT" -q "$QUALITY" -- "$FILE_INPUT" && {
    time_get && STATS="in $MILLISEC ms"

    RESULT_PNG="$FILE_OUTPUT.$SETTINGS.png"
    ba || ss && dwebp -quiet -o "$RESULT_PNG" -- "$FILE_OUTPUT"

    do_butteraugli "$FILE_INPUT" "$RESULT_PNG"
    do_ssimulacra2 "$FILE_INPUT" "$RESULT_PNG"
    rm -f "$RESULT_PNG"
  }
}

do_heif_heifenc()
{
  heif-enc -p preset=veryslow --quality "$QUALITY" -o "$FILE_OUTPUT" "$FILE_INPUT" && {
    time_get && STATS="in $MILLISEC ms"

    RESULT_PNG="$FILE_OUTPUT.$SETTINGS.png"
    ba || ss && heif-dec --quiet "$FILE_OUTPUT" "$RESULT_PNG"

    do_butteraugli "$FILE_INPUT" "$RESULT_PNG"
    do_ssimulacra2 "$FILE_INPUT" "$RESULT_PNG"
    rm -f "$RESULT_PNG"
  }
}

do_png_pngquant()
{
  pngquant --strip --speed 1 --nofs --force --quality "$QUALITY" --output "$FILE_OUTPUT" -- "$FILE_INPUT" || { local rc=$?; test "$rc" = 99 || return "$rc"; }
  zopflipng -y --filters="01234meb" "$FILE_OUTPUT" "$FILE_OUTPUT-" && cat "$FILE_OUTPUT-" >"$FILE_OUTPUT" && rm -f "$FILE_OUTPUT-" && {
    time_get && STATS="in $MILLISEC ms"

    do_butteraugli "$FILE_INPUT" "$FILE_OUTPUT"
    do_ssimulacra2 "$FILE_INPUT" "$FILE_OUTPUT"
  }
}

ff()	# format float: e.g.  '1.23456'
{	#     rightpadded => ' 1.23'
  local float="$1"
  float="$( LC_ALL=C printf '%.2f' "$float" )"
  printf '%5s' "$float"
}

do_butteraugli()	# can read jpeg or png, for 'butteraujxl' we omit the default: --pnorm 3
{			# butteraujxl has other values/defaults: https://github.com/libjxl/libjxl/issues/2548
  local file_good="$1"		# reference/original
  local file_fake="$2"		# distorted
  ba || return 0

  time_start && BA="$( butteraugli "$file_good" "$file_fake" )"            && time_get && STATS="$STATS butteraugli: $( ff "$BA" ) in $MILLISEC ms"
  time_start && BA="$( butteraujxl "$file_good" "$file_fake" | head -n1 )" && time_get && STATS="$STATS butteraujxl: $( ff "$BA" ) in $MILLISEC ms"
}

do_ssimulacra2()	# can read jpeg or png
{
  local file_good="$1"		# reference/original
  local file_fake="$2"		# distorted
  ss || return 0

  time_start && SS="$( ssimulacra2  "$file_good" "$file_fake" )" && time_get && STATS="$STATS ssimulacra2: $( ff "$SS" ) in $MILLISEC ms"
  time_start && SS="$( fssimu2 2>&1 "$file_good" "$file_fake" )" && time_get && STATS="$STATS fssimu2: $(     ff "$SS" ) in $MILLISEC ms"
}

time_start()
{
  # https://stackoverflow.com/questions/16548528/linux-command-to-get-time-in-milliseconds
  export MILLISEC=
  read -r UP _ </proc/uptime; T0="${UP%.*}${UP#*.}"
}

time_get()
{
  read -r UP _ </proc/uptime; T1="${UP%.*}${UP#*.}"
  MILLISEC=$(( 10*(T1-T0) ))
  MILLISEC=$( printf '%5s' "$MILLISEC" )
}

work()
{
  command -v "do_${FAMILY}_${ENCODER}" >/dev/null 2>/dev/null || return 0
  test -s "$FILE_OUTPUT" && return 0	# already done
  I=$(( I + 1 ))

  # TODO: wait for nproc or load? (otherwise timing says nothing)

  ONCE=
  CONCURRENT="$( find "$TARGET_DIR" -type f -name 'queued-*' -printf x | wc -c )"
  while [ "$CONCURRENT" -gt "$PARALLEL" ]; do {
    test -z "$ONCE" && ONCE=true && log "[OK] waiting for free slot, $CONCURRENT running vs. max $PARALLEL"
    sleep 1
    CONCURRENT="$( find "$TARGET_DIR" -type f -name 'queued-*' -printf x | wc -c )"
  } done

  (
    printf '%s\n' "$$" >"$TARGET_DIR/queued-$I"
    S1="$( printf '%-4s' "$FAMILY" )"
    S2="$( printf '%-8s' "$ENCODER" )"
    S3="$( printf '%-20s' "$SETTINGS" )"

    STATS= && time_start
    if "do_${FAMILY}_${ENCODER}" >/dev/null 2>/dev/null; then
      FILESIZE="$( stat -c %s "$FILE_OUTPUT" )"
      FILESIZE="$( printf '%7s' "$FILESIZE" )"
      echo "family: $S1 encoder: $S2 settings: $S3 filesize: $FILESIZE bytes $STATS" >"$FILE_OUTPUT.stats"
#     test "$MYSETTINGS" = all || log "[OK] ready '$SETTINGS' - scp $FILE_OUTPUT $SCP_TARGET"
    else
      RC=$?
      log "[ERROR:$RC] $SETTINGS"
      echo "family: $S1 encoder: $S2 settings: $S3 rc: ERROR:$RC $STATS" >"$FILE_OUTPUT.stats"
    fi

    mv "$TARGET_DIR/queued-$I" "$TARGET_DIR/ready-$I"
  ) &
}

queue_empty()
{
  JOBS_READY="$( find "$TARGET_DIR" -type f -name 'ready-*' -printf x | wc -c )"
  JOBS_NEEDED=$(( I - JOBS_READY ))
# log "[DEBUG] jobs: $JOBS_READY vs. $I in dir '$TARGET_DIR'"
  test "$JOBS_READY" = "$I"
}

output_gnuplut()
{
	cat <<EOF
FILE = "$TARGET_DIR/plot.csv"
FILE2 = "$TARGET_DIR/plot2.csv"
OUT = "$TARGET_DIR/plot.svg"
ORIG = $SIZE_ORIGINAL

set datafile separator whitespace
set term svg size 1920,1080 dynamic enhanced background "white"
set output OUT

# https://easystats.github.io/see/reference/scale_color_okabeito.html
OKABE(i) = (i==1) ? "#E69F00" : \\
           (i==2) ? "#56B4E9" : \\
           (i==3) ? "#009E73" : \\
           (i==4) ? "#F0E442" : \\
           (i==5) ? "#0072B2" : \\
           (i==6) ? "#D55E00" : \\
           (i==7) ? "#CC79A7" : "#000000"

ENCODERS = "avifenc cjpegli cjxl cwebp guetzli mozjpeg pngquant heifenc"

enc_color(enc) = (enc eq "avifenc")  ? OKABE(1) : \\
                 (enc eq "cjpegli")  ? OKABE(2) : \\
                 (enc eq "cjxl")     ? OKABE(3) : \\
                 (enc eq "cwebp")    ? OKABE(4) : \\
                 (enc eq "guetzli")  ? OKABE(5) : \\
                 (enc eq "mozjpeg")  ? OKABE(6) : \\
                 (enc eq "pngquant") ? OKABE(7) : \\
                 (enc eq "heifenc")  ? OKABE(8) : "#999999"

set style line 1 pt 7 ps 1.0 lw 2

stats FILE using 4 nooutput

set autoscale x
set xrange [0:*]
set x2range [0:100]

set link x2 via (100.0*x/ORIG) inverse (ORIG*x/100.0)
set x2tics
set x2label "filesize in [%] from original"

set multiplot layout 6,1 margins 0.08,0.98,0.06,0.98 spacing 0.06,0.1

unset grid; set grid back
set key top right

set xlabel "filesize in [bytes]"
set ylabel "butteraugli score (higher is better)"
set yrange [] reverse

set label 101 "butteraugli-standard" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$5 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

set xlabel "filesize in [bytes]"
set ylabel "butteraugli score (higher is better)"
set yrange [] reverse

set label 101 "butteraugli-standard (interesting selection)" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE2 using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$5 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

set xlabel "filesize in [bytes]"
set ylabel "butteraugli-jxl score (higher is better)"
set yrange [] reverse

set label 101 "butteraugli-jxl" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$6 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

set xlabel "filesize in [bytes]"
set ylabel "butteraugli-jxl score (higher is better)"
set yrange [] reverse

set label 101 "butteraugli-jxl (interesting selection)" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE2 using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$6 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

set xlabel "filesize in [bytes]"
set ylabel "ssimulacra2 score (higher is better)"
unset yrange

set label 101 "ssimulacra2" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$7 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

set xlabel "filesize in [bytes]"
set ylabel "ssimulacra2 score (higher is better)"
unset yrange

set label 101 "ssimulacra2 (interesting selection)" at graph 0, 1.10 left front font ",24"
plot for [enc in ENCODERS] FILE2 using \\
    ( stringcolumn(1) eq enc ? \$3 : 1/0 ) : \\
    ( stringcolumn(1) eq enc ? \$7 : 1/0 ) \\
    with linespoints ls 1 lc rgb enc_color(enc) title enc

unset multiplot
set output
EOF
}

cleanup()
{
  test -n "$T2" && return
  log && log "[OK] will stop remaining jobs"

  # shellcheck disable=SC2044
  for JOBFILE in $( find "$TARGET_DIR" -type f -name 'queued-*' ); do {
    read -r PID <"$JOBFILE" && log "     PID: $PID" && kill -0 "$PID" && kill "$PID"
  } done
}

SCP_TARGET="root@show.quicky.club:/var/www/show.quicky.club/html/results/1234/image-hcoTgAmLF3RK-560px-original.png"
[ -n "$UPLOAD" ] && log "[OK] scp $FILE_INPUT $SCP_TARGET"

trap cleanup EXIT INT

for FAMILY in heif png jpeg jxl avif webp; do {
  for COLOR in all $LIST_COLORS; do {
    for ENCODER in heifenc pngquant guetzli cjxl avifenc cwebp mozjpeg cjpegli; do {
      for QUALITY in 75 70 60 55 50 45 40 35 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1; do {
        SETTINGS="$FAMILY-$COLOR-$ENCODER-q$QUALITY"

	WORK=
	test "$MYSETTINGS" = all && WORK=true
	case "$SETTINGS" in "$MYSETTINGS"*|"$MYSETTINGS") WORK=true ;; esac

	test "$ENCODER" = guetzli && test "$QUALITY" = 75 && QUALITY=84		# lower is not possible, more is too good
	test "$ENCODER" = guetzli && test "$QUALITY" -lt 84 && WORK=
	test "$WORK" = true || continue

	FILE_OUTPUT="$TARGET_DIR/image-$SETTINGS.$FAMILY"
	SCP_TARGET="root@show.quicky.club:/var/www/show.quicky.club/html/results/1234/image-hcoTgAmLF3RK-560px-$SETTINGS.$FAMILY"
	work
      } done
    } done
  } done
} done

CPU="$( grep "model name" /proc/cpuinfo | head -n1 )"
GHZ="$( grep 'cpu MHz' /proc/cpuinfo | head -1 | awk -F: '{print $2/1024}' )"

{
	echo
	echo "# $( LC_ALL=C date )"
	echo "# $( nproc ) x $CPU at $GHZ GHz"
	echo "# reproduce result with:"
	echo "cd $PWD && $REPRODUCER"
} >>"$TARGET_DIR/stats-system.txt"

while ! queue_empty; do test "$LAST" = "$JOBS_NEEDED" || log "[OK] waiting for $JOBS_NEEDED remaining jobs"; LAST="$JOBS_NEEDED" && sleep 1; done

T2="$( date +%s )" && rm -f "$TARGET_DIR/ready-"* "$TEMP_PNG" && {
	# stable sort of settings:
	cat "$TARGET_DIR/"*.stats | sort -V -k6,6 >"$TARGET_DIR/stats.txt"

	# family: avif encoder: avifenc settings: avif-all-avifenc-q25 filesize: 16929 bytes in 870 ms butteraugli: 19.71 in 8260 ms butteraujxl: 14.44 in 540 ms ssimulacra2: 51.57 in 270 ms
	#                       ^^^^^^^           ^^^^^^^^^^^^^^^^^^^^           ^^^^^                              ^^^^^                         ^^^^^                        ^^^^^
	cat "$TARGET_DIR/stats.txt" | sort -n -k8,8 | awk -v s="$SIZE_ORIGINAL"           '{print $4,$6,$8,s,$14,$19,$24}' >"$TARGET_DIR/plot.csv"
	cat "$TARGET_DIR/stats.txt" | sort -n -k8,8 | awk -v s="$SIZE_ORIGINAL" '{if($24>50)print $4,$6,$8,s,$14,$19,$24}' >"$TARGET_DIR/plot2.csv"
	output_gnuplut >"$TARGET_DIR/plot.gnuplot"
	gnuplot "$TARGET_DIR/plot.gnuplot"

	echo "# took $(( T2 - TS )) seconds for $I conversions" >>"$TARGET_DIR/stats-system.txt"
	log "[OK] ready in $(( T2 - TS )) seconds for $I conversions"
	log "     see directory: $TARGET_DIR"
	log
	log "     see stats: $TARGET_DIR/stats.txt"
	log "           and: $TARGET_DIR/stats-system.txt"
	log "           and: $TARGET_DIR/plot.svg"
}
