### Link

![thisrepo.qrcode](https://show.quicky.club/url/url1.svg)

### What

convert an image into many web-formats (e.g. jpeg-xl, heif, avif, jpeg, png, webp, ...) with different quality settings for reducing filesize.

### Usage

```
# prepare a testimage, e.g.:
# originally from https://jpegxl.info/images/precision-machinery-shapes-golden-substance-with-robotic-exactitude.jpg

$ URL="http://intercity-vpn.de/files/2025-10-04/upload/precision-machinery-shapes-golden-substance-with-robotic-exactitude.png"
$ INPUT=~/precision-machinery-shapes-golden-substance-with-robotic-exactitude.png
$ curl -so "$INPUT" "$URL"

# run script:
$ quicky.sh "$INPUT" all --butteraugli --ssimulacra2 --parallel 30
...
[OK] ready in 313 seconds for 274 conversions
     see directory: /tmp/tmp.6cQyTVxqpc-converted

     see stats: /tmp/tmp.6cQyTVxqpc-converted/stats.txt
           and: /tmp/tmp.6cQyTVxqpc-converted/stats-system.txt
           and: /tmp/tmp.6cQyTVxqpc-converted/plot.svg

$ grep "q15\|q16\|q17" /tmp/tmp.6cQyTVxqpc-converted/stats.txt
family: avif encoder: avifenc  settings: avif-all-avifenc-q15 filesize:   12015 bytes in  6110 ms butteraugli: 18.91 in 67640 ms butteraujxl: 13.55 in  6160 ms ssimulacra2: 31.99 in  1530 ms fssimu2: 30.01 in   940 ms
family: avif encoder: avifenc  settings: avif-all-avifenc-q16 filesize:   12515 bytes in  1960 ms butteraugli: 17.96 in 51570 ms butteraujxl: 14.26 in  3460 ms ssimulacra2: 35.12 in  1460 ms fssimu2: 33.27 in   410 ms
family: avif encoder: avifenc  settings: avif-all-avifenc-q17 filesize:   13230 bytes in  1900 ms butteraugli: 18.60 in 55160 ms butteraujxl: 11.19 in  2650 ms ssimulacra2: 38.55 in  1760 ms fssimu2: 36.69 in   580 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q15 filesize:   11556 bytes in  4110 ms butteraugli: 18.39 in 54380 ms butteraujxl: 13.44 in  4170 ms ssimulacra2: 33.00 in  1880 ms fssimu2: 31.25 in  1250 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q16 filesize:   11556 bytes in  4140 ms butteraugli: 18.39 in 39700 ms butteraujxl: 13.44 in  3460 ms ssimulacra2: 33.00 in  1880 ms fssimu2: 31.25 in   820 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q17 filesize:   12559 bytes in  4050 ms butteraugli: 17.39 in 43840 ms butteraujxl: 12.38 in  4850 ms ssimulacra2: 37.85 in   660 ms fssimu2: 36.25 in   950 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q15 filesize:   35266 bytes in   320 ms butteraugli:  9.77 in 45260 ms butteraujxl:  6.76 in  4690 ms ssimulacra2: 45.08 in  1420 ms fssimu2: 43.17 in  1020 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q16 filesize:   36482 bytes in   210 ms butteraugli:  8.05 in 53920 ms butteraujxl:  6.77 in  5110 ms ssimulacra2: 47.27 in  2340 ms fssimu2: 45.52 in  1310 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q17 filesize:   37655 bytes in   200 ms butteraugli:  8.26 in 40690 ms butteraujxl:  6.75 in  1790 ms ssimulacra2: 48.34 in   610 ms fssimu2: 46.28 in   230 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q15 filesize:   24103 bytes in   840 ms butteraugli: 14.18 in 54200 ms butteraujxl:  8.79 in  2820 ms ssimulacra2: 17.95 in   840 ms fssimu2: 13.90 in   930 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q16 filesize:   25210 bytes in   300 ms butteraugli: 13.22 in 44150 ms butteraujxl:  8.42 in  1620 ms ssimulacra2: 21.52 in  1110 ms fssimu2: 17.62 in   680 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q17 filesize:   26315 bytes in   230 ms butteraugli: 13.68 in 51350 ms butteraujxl:  8.10 in  3540 ms ssimulacra2: 24.65 in   600 ms fssimu2: 21.15 in   700 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q15     filesize:   20159 bytes in  7580 ms butteraugli: 14.94 in 68360 ms butteraujxl:  9.33 in  3100 ms ssimulacra2: 41.38 in  1210 ms fssimu2: 40.08 in  1380 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q16     filesize:   20867 bytes in 12460 ms butteraugli: 17.21 in 56520 ms butteraujxl:  9.55 in  3680 ms ssimulacra2: 43.30 in  1710 ms fssimu2: 42.39 in  1630 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q17     filesize:   21641 bytes in 10770 ms butteraugli: 14.48 in 44590 ms butteraujxl:  9.11 in  1300 ms ssimulacra2: 45.51 in  2660 ms fssimu2: 44.58 in   980 ms
family: png  encoder: pngquant settings: png-all-pngquant-q15 filesize:   86171 bytes in 225590 ms butteraugli: 21.83 in 47970 ms butteraujxl: 16.76 in  3560 ms ssimulacra2:  9.44 in  1580 ms fssimu2:  5.79 in   850 ms
family: png  encoder: pngquant settings: png-all-pngquant-q16 filesize:   86733 bytes in 220490 ms butteraugli: 21.83 in 43780 ms butteraujxl: 16.76 in  3090 ms ssimulacra2:  9.50 in  1490 ms fssimu2:  5.87 in   930 ms
family: png  encoder: pngquant settings: png-all-pngquant-q17 filesize:   88076 bytes in 233150 ms butteraugli: 20.81 in 42330 ms butteraujxl: 16.18 in  3790 ms ssimulacra2: 10.53 in  2270 ms fssimu2:  6.90 in   550 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q15   filesize:   24486 bytes in   660 ms butteraugli: 11.68 in 61700 ms butteraujxl:  7.85 in  1180 ms ssimulacra2: 47.22 in   700 ms fssimu2: 45.82 in   270 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q16   filesize:   25126 bytes in   510 ms butteraugli: 11.94 in 55480 ms butteraujxl:  7.69 in  2620 ms ssimulacra2: 48.62 in  1020 ms fssimu2: 47.24 in   790 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q17   filesize:   25438 bytes in   440 ms butteraugli: 11.61 in 52570 ms butteraujxl:  8.39 in  2860 ms ssimulacra2: 48.80 in  1110 ms fssimu2: 47.46 in   210 ms
```

### API

```
URL='https://show.quicky.club/api/v1/img'
APIKEY='maschinenraum'
AUTH="Authorization: Bearer $APIKEY"

FILE=/path/to/an/image
cat $FILE | curl -sH "$AUTH" -F "data=@-" -F "width=123" $URL
```

see: https://show.quicky.club/results/1234/image-hcoTgAmLF3RK-560px.html


### ToDo
* dockerimage
* binary download
* compile steps
