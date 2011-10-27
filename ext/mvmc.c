#include <stdarg.h>
#include <stdio.h>
#define streq(s1, s2) (strcmp((s1),(s2)) == 0)

void usage() {
    printf("hm, ok.");
}

void error(const char* msg, ...) {
    va_list ap;
    va_start(ap, msg);
    fprintf(stderr, "ERROR: ");
    vfprintf(stderr, msg, ap);
    fprintf(stderr, "\n");
    va_end(ap);
}

int main(int argc, char *argv[]) {
    if(argc < 2) {
        usage();
        return 1;
    }

    if(streq(argv[1], "help")) {
        usage(); return 0;
    } else if(streq(argv[1], "curr")) {
    } else error("Unknown command %s. Try 'help'.", argv[1]);
}


