NIFDIR := `erl -eval 'io:format("~s", [code:lib_dir(erts,include)])' -s init stop -noshell| sed s'/erlang\/lib\//erlang\//'`
NIF_FLAGS := `ruby -rrbconfig -e 'puts Config::CONFIG["LDSHARED"]'` -O3 -fPIC -fno-common -Wall

MPEG2 := -lmpeg2
MPEG2 := libmpeg2/*.o

# vpath %.c libmpeg2
LIBMPEG2_SRCS = $(wildcard libmpeg2/*.c)
LIBMPEG2_OBJS = $(LIBMPEG2_SRCS:.c=.o)


all:  ebin/ems_video.so ebin/ems_sound2.so compile

compile:
	ERL_LIBS=../erlyvideo/apps erl -make

ebin/ems_video.so: src/ems_video.c src/ems_x264.c src/ems_mpeg2.c libmpeg2_objs
	gcc -c -o ebin/ems_video.o src/ems_video.c -I $(NIFDIR)
	gcc -shared -undefined dynamic_lookup -o $@ ebin/libswscale.a ebin/ems_video.o -g ebin/libx264.a -lavutil $(MPEG2)

ebin/ems_sound2.so: src/ems_sound2.c src/ems_mpg123.c src/ems_faac.c
	gcc -c -o ebin/ems_sound2.o src/ems_sound2.c -I $(NIFDIR)
	gcc -shared -undefined dynamic_lookup -o $@ ebin/ems_sound2.o -g -lmpg123 -lfaac

libmpeg2_objs: $(LIBMPEG2_OBJS)

libmpeg2/%.o: libmpeg2/%.c
	gcc -c -g $< -o $@ #-I${NIFDIR}


ebin/readjpeg.o: src/readjpeg.c
	gcc -c src/readjpeg.c -g -o ebin/readjpeg.o

clean:
	@rm -f test ebin/*.o ebin/*.so libmpeg2/*.o libmpeg2/*.d
