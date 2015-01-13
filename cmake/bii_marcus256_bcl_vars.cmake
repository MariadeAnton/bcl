
# LIBRARY marcus256_bcl ##################################

# Source code files of the library
SET(BII_LIB_SRC  src/huffman.c
			src/huffman.h
			src/lz.c
			src/lz.h
			src/rice.c
			src/rice.h
			src/rle.c
			src/rle.h
			src/shannonfano.c
			src/shannonfano.h
			src/systimer.c
			src/systimer.h)
# STATIC by default if empty, or SHARED
SET(BII_LIB_TYPE )
# Dependencies to other libraries (user2_block2, user3_blockX)
SET(BII_LIB_DEPS )
# System included headers
SET(BII_LIB_SYSTEM_HEADERS stdlib.h sys/time.h time.h windows.h)
# Required include paths
SET(BII_LIB_INCLUDE_PATHS )


# Executables to be created
SET(BII_BLOCK_EXES src_bcltest
			src_bfc)



# EXECUTABLE src_bfc ##################################

SET(BII_src_bfc_SRC src/bfc.c)
SET(BII_src_bfc_DEPS marcus256_bcl)
# System included headers
SET(BII_src_bfc_SYSTEM_HEADERS stdio.h stdlib.h string.h)
# Required include paths
SET(BII_src_bfc_INCLUDE_PATHS )


# EXECUTABLE src_bcltest ##################################

SET(BII_src_bcltest_SRC src/bcltest.c)
SET(BII_src_bcltest_DEPS marcus256_bcl)
# System included headers
SET(BII_src_bcltest_SYSTEM_HEADERS stdio.h stdlib.h string.h)
# Required include paths
SET(BII_src_bcltest_INCLUDE_PATHS )
