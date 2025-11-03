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
```

### ToDo
* dockerimage
* binary download
* compile steps
