#Bassic Compresion Library [![Build Status](https://travis-ci.org/MariadeAnton/bcl.svg?branch=master)](https://travis-ci.org/MariadeAnton/bcl)
This is an adaptation of the [original bcl library](http://bcl.comli.eu/)  to enable its use with Biicode.

[Github repository link](https://github.com/MariadeAnton/bcl)

[Biicode repository link](http://www.biicode.com/marcus256/bcl)


# Basic Compression Library

by Marcus Geelnard

Release 1.2.0

2006-07-22

## Introduction

The Basic Compression Library is a library of well known compression
  algorithms implemented in portable ANSI C code.

Currently, RLE (Run Length Encoding), Huffman, Rice, Lempel-Ziv (LZ77) and Shannon-Fano compression algorithms are implemented.

For more information about the Basic Compression Library, please read
  the manual ([doc/manual.pdf](doc/manual.pdf)) and, of course,
  the source code.

## Version History

### 1.2.0 (2006.07.22)

*   As Tomasz Cichocki kindly pointed out, the Huffman coder that was
    implemented in versions 1.1.3 and earlier was actually a Shannon-Fano
    coder. The coder was accordingly renamed.
*   A new, true Huffman coder was created. It is very similar to the
    Shannon-Fano coder, but it compresses slightly better. The new Huffman
    decoder is not compatible with the Huffman decoder in version 1.1.3,
    so it can not handle compressed data generated with older versions of
    the library.
*   Fixed a compilation warning for Visual C++ in the LZ coder
    (thanks Yuval Ofer!).

### 1.1.3 (2006.07.06)

*   Improved the Huffman decompression speed with about 400%, and at
    the same time made the source code easier to understand (hopefully).

### 1.1.2 (2006.06.26)

*   The "fast" LZ compression algortihm is now even faster, since the
        search window is limited, just as it is in the standard LZ
        compression algorithm.
*   The test application (bcltester) now measures the compression and
        decompression speeds.
*   Removed the -Wtraditional flag from the Makefile.
*   Updated some paragraphs in the documentation.
*   Changed the readme-file from text to HTML.
*   Moved from CVS to Subversion revision control system.

### 1.1.1 (2004.12.25)

*   Bugfix in rle.c: When exactly three sequential bytes equal to the
        marker byte occured in the input stream, the coder output one byte too
        many.

### 1.1.0 (2004.12.14)

*   Bugfix in rice.c: Changed internal signed magnitude format in order to
        support all possible signed values. As a result, data that has been
        compressed with rice.c in v1.0.6 is no longer compatible with v1.1.0!
*   Bugfix in huffman.c: The Huffman tree was not optimally balanced, so
        incompressible data would overflow the output buffer (effectively
        rendering the compressed data invalid). The fixed Huffman coder should
        compress slightly better than the old 1.0.6 coder.
*   A new faster LZ77 coder (LZ_CompressFast).
*   Added a compression test utility (bcltester.c).

### 1.0.6 (2004.05.22)

*   Bugfix in the LZ77 decoder.

### 1.0.5 (2004.05.09)

*   Added a LZ77 coder/decoder.

### 1.0.4 (2004.04.21)

*   Bugfix in rle.c: Long runs would be truncated (thanks Steve!).

### 1.0.3 (2004.02.17)

*   The project was moved to Sourceforge.
*   Changed license to the zlib license.

### 1.0.2 (2003.10.04)

*   Improved Rice compression.

### 1.0.1 (2003.10.01)

*   Added Rice compression.
*   Added bfc, the Basic File Compressor :)

### 1.0.0 (2003.09.29)

*   Initial release.
*   RLE and Huffman compression
