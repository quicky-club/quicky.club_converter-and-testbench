### Link

![thisrepo.qrcode](https://show.quicky.club/url/url1.svg)

### What

convert any image into all formats (e.g. jpeg-xl, heif, avif, jpeg, png, webp, ...) and many different quality settings for reducing filesize.

### Usage

```
# prepare a testimage, e.g.:
# originally from https://jpegxl.info/images/precision-machinery-shapes-golden-substance-with-robotic-exactitude.jpg

$ URL="http://intercity-vpn.de/files/2025-10-04/upload/precision-machinery-shapes-golden-substance-with-robotic-exactitude.png"
$ INPUT=~/precision-machinery-shapes-golden-substance-with-robotic-exactitude.png
$ curl -so "$INPUT" "$URL"

# run script:
$ convert.sh "$INPUT" all --parallel 30
...
[OK] ready in 313 seconds for 274 conversions
     see directory: /tmp/tmp.6cQyTVxqpc-converted

     see stats: /tmp/tmp.6cQyTVxqpc-converted/stats.txt
           and: /tmp/tmp.6cQyTVxqpc-converted/stats-system.txt
           and: /tmp/tmp.6cQyTVxqpc-converted/plot.svg

$ grep "q15\|q16\|q17" /tmp/tmp.6cQyTVxqpc-converted/stats.txt
family: avif encoder: avifenc  settings: avif-all-avifenc-q15 filesize:   12015 bytes in  2590 ms
family: avif encoder: avifenc  settings: avif-all-avifenc-q16 filesize:   12515 bytes in  3390 ms
family: avif encoder: avifenc  settings: avif-all-avifenc-q17 filesize:   13230 bytes in  3060 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q15 filesize:   11556 bytes in  4710 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q16 filesize:   11556 bytes in  4190 ms
family: heif encoder: heifenc  settings: heif-all-heifenc-q17 filesize:   12559 bytes in  4300 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q15 filesize:   35266 bytes in   260 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q16 filesize:   36482 bytes in   240 ms
family: jpeg encoder: cjpegli  settings: jpeg-all-cjpegli-q17 filesize:   37655 bytes in   280 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q15 filesize:   24103 bytes in   340 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q16 filesize:   25210 bytes in   520 ms
family: jpeg encoder: mozjpeg  settings: jpeg-all-mozjpeg-q17 filesize:   26315 bytes in   530 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q15     filesize:   20159 bytes in 11240 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q16     filesize:   20867 bytes in  9890 ms
family: jxl  encoder: cjxl     settings: jxl-all-cjxl-q17     filesize:   21641 bytes in 12550 ms
family: png  encoder: pngquant settings: png-all-pngquant-q15 filesize:   86171 bytes in 208610 ms
family: png  encoder: pngquant settings: png-all-pngquant-q16 filesize:   86733 bytes in 213110 ms
family: png  encoder: pngquant settings: png-all-pngquant-q17 filesize:   88076 bytes in 230740 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q15   filesize:   24486 bytes in   370 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q16   filesize:   25126 bytes in   360 ms
family: webp encoder: cwebp    settings: webp-all-cwebp-q17   filesize:   25438 bytes in   360 ms
```

### ToDo
* dockerimage
* binary download
* compile steps
