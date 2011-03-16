#!/bin/sh
gcc avatar.c -o avatar `sdl-config --cflags --libs` -lGL -lGLU -lm -I/usr/include/SDL -I/usr/local/include/SDL
