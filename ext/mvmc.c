#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>

#define streq(s1, s2) (strcmp((s1),(s2)) == 0)

#define PATHSIZE 1024
#define MCDIR "/.metacon"
#define MCDIR_L 9

char root_dir[PATHSIZE];

void usage() {
    printf("USAGE: Not really usable yet\n");
}

void error(const char* msg, ...) {
    va_list ap;
    va_start(ap, msg);
    fprintf(stderr, "ERROR: ");
    vfprintf(stderr, msg, ap);
    fprintf(stderr, "\n");
    va_end(ap);
}

int find_root_dir() {
    getcwd(root_dir, PATHSIZE - MCDIR_L - 3);
    if(root_dir == NULL) {
        error("Couldn't open current directory");
        exit(3);
    }
    int endpos = strlen(root_dir);
    do {
        memcpy(&root_dir[endpos], MCDIR, MCDIR_L+1);
        if(access(root_dir, X_OK) == 0) return 1;
    } while( (endpos = go_up(root_dir)) );
    return 0;
}

int go_up(char *dir) {
    int i = 0;
    int last_pos = 0;
    int last_pos2 = 0;
    char ch;
    while((ch = dir[i])) {
        if(ch == '/' || ch == '\\') {
            if(dir[i+1]) {
                last_pos2 = last_pos;
                last_pos = i; // don't count if trailing slash
            }
        }
        i++;
    }
    return last_pos2;
}

int main(int argc, char *argv[]) {
    if(argc < 2) {
        usage();
        return 1;
    }

    /* --Commands--
     * [very, very fast]
     * help
     * curr
     * ps1
     * conf
     * * - anything else and it triggers it under current context
     *
     * [fast]
     * refresh (to ensure dependencies etc. without switching)
     * stat
     * branch  (current/list/set)(via git of course)
     * role    (current/list/set)
     * ctx     (current/list/set)(rtc...)
     * os      (current/list/(set?))
     * host    (current/list/(set?))
     *
     */

    if(streq(argv[1], "help")) {
        usage(); return 0;
    } else if(streq(argv[1], "curr")) {
        if(find_root_dir()) {
            printf("----| %s |----\n", root_dir);
        } else {
            error("Not in a metacon project.");
        }
    } else error("Unknown command %s. Try 'help'.", argv[1]);
}

