#import <Foundation/Foundation.h>
#import <spawn.h>
#import <errno.h>
#import <string.h>
#import <stdio.h>
#import <unistd.h>
#import <sys/wait.h>

extern char **environ;

#define POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE 1

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "usage: ido <command> <args...>\n");
        return 1;
    }

    if (strcmp(argv[1], "--version") == 0) {
        fprintf(stdout, "ido 1.0 – A sudo alternative for iOS\n");
        fprintf(stdout, "(c) 2023 BomberFish Industries.\n");
        return 0;
    }

    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_set_persona_np(&attr, 99, POSIX_SPAWN_PERSONA_FLAGS_OVERRIDE);
    posix_spawnattr_set_persona_uid_np(&attr, 0);
    posix_spawnattr_set_persona_gid_np(&attr, 0);

    pid_t pid;
    int status = posix_spawnp(&pid, argv[1], NULL, &attr, &argv[1], environ);

    posix_spawnattr_destroy(&attr);

    if (status != 0) {
        fprintf(stderr, "failed to spawn %s: %s\n", argv[1], strerror(errno));
        return 1;
    }

    waitpid(pid, &status, 0);
    return WEXITSTATUS(status);
}
