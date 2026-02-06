#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
#include <objc/runtime.h>
#include <objc/message.h>

typedef struct {
    int hour;
    int minute;
} Time;

typedef struct {
    Time fromTime;
    Time toTime;
} Schedule;

typedef struct {
    char active;
    char enabled;
    char sunSchedulePermitted;
    char mode;
    Schedule schedule;
    unsigned long long disableFlags;
    char available;
} Status;

static void *load_corebrightness(void) {
    void *handle = dlopen("/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness", RTLD_LAZY);
    if (!handle) {
        fprintf(stderr, "Error: Failed to load CoreBrightness framework: %s\n", dlerror());
        return NULL;
    }
    return handle;
}

static void *get_client(void) {
    static void *cb_handle = NULL;
    if (!cb_handle) {
        cb_handle = load_corebrightness();
        if (!cb_handle) return NULL;
    }
    
    Class CBBlueLightClient = objc_getClass("CBBlueLightClient");
    if (!CBBlueLightClient) {
        fprintf(stderr, "Error: CBBlueLightClient not found\n");
        return NULL;
    }
    
    id client = ((id (*)(Class, SEL))objc_msgSend)(CBBlueLightClient, sel_registerName("alloc"));
    if (!client) {
        fprintf(stderr, "Error: Failed to alloc CBBlueLightClient\n");
        return NULL;
    }
    
    client = ((id (*)(id, SEL))objc_msgSend)(client, sel_registerName("init"));
    if (!client) {
        fprintf(stderr, "Error: Failed to init CBBlueLightClient\n");
        return NULL;
    }
    
    return client;
}

static int get_status(void *client, Status *status) {
    if (!client || !status) return 0;
    
    int (*getBlueLightStatus)(id, SEL, Status*) = (int (*)(id, SEL, Status*))objc_msgSend;
    return getBlueLightStatus((id)client, sel_registerName("getBlueLightStatus:"), status);
}

static int set_enabled(void *client, int enabled) {
    if (!client) return 0;
    
    int (*setEnabled)(id, SEL, int) = (int (*)(id, SEL, int))objc_msgSend;
    return setEnabled((id)client, sel_registerName("setEnabled:"), enabled);
}

static void show_status(void) {
    void *client = get_client();
    if (!client) {
        fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
        exit(1);
    }
    
    Status status;
    memset(&status, 0, sizeof(status));
    
    if (!get_status(client, &status)) {
        fprintf(stderr, "Error: Failed to get Night Shift status\n");
        exit(1);
    }
    
    printf("Night Shift: %s\n", status.enabled ? "on" : "off");
    
    ((void (*)(id, SEL))objc_msgSend)((id)client, sel_registerName("release"));
}

static void toggle(void) {
    void *client = get_client();
    if (!client) {
        fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
        exit(1);
    }
    
    Status status;
    memset(&status, 0, sizeof(status));
    
    if (!get_status(client, &status)) {
        fprintf(stderr, "Error: Failed to get Night Shift status\n");
        exit(1);
    }
    
    int new_state = !status.enabled;
    if (!set_enabled(client, new_state)) {
        fprintf(stderr, "Error: Failed to toggle Night Shift\n");
        exit(1);
    }
    
    printf("Night Shift: %s -> %s\n", status.enabled ? "on" : "off", new_state ? "on" : "off");
    
    ((void (*)(id, SEL))objc_msgSend)((id)client, sel_registerName("release"));
}

static void set_on(void) {
    void *client = get_client();
    if (!client) {
        fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
        exit(1);
    }
    
    if (!set_enabled(client, 1)) {
        fprintf(stderr, "Error: Failed to enable Night Shift\n");
        exit(1);
    }
    
    printf("Night Shift: on\n");
    
    ((void (*)(id, SEL))objc_msgSend)((id)client, sel_registerName("release"));
}

static void set_off(void) {
    void *client = get_client();
    if (!client) {
        fprintf(stderr, "Error: Failed to create CBBlueLightClient\n");
        exit(1);
    }
    
    if (!set_enabled(client, 0)) {
        fprintf(stderr, "Error: Failed to disable Night Shift\n");
        exit(1);
    }
    
    printf("Night Shift: off\n");
    
    ((void (*)(id, SEL))objc_msgSend)((id)client, sel_registerName("release"));
}

static void show_usage(const char *prog) {
    printf("Usage: %s <command>\n\n", prog);
    printf("Commands:\n");
    printf("  toggle    Toggle Night Shift on/off\n");
    printf("  on        Enable Night Shift\n");
    printf("  off       Disable Night Shift\n");
    printf("  status    Show current status\n");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        show_usage(argv[0]);
        return 1;
    }
    
    const char *cmd = argv[1];
    
    if (strcmp(cmd, "toggle") == 0) {
        toggle();
    } else if (strcmp(cmd, "on") == 0) {
        set_on();
    } else if (strcmp(cmd, "off") == 0) {
        set_off();
    } else if (strcmp(cmd, "status") == 0) {
        show_status();
    } else {
        fprintf(stderr, "Unknown command: %s\n\n", cmd);
        show_usage(argv[0]);
        return 1;
    }
    
    return 0;
}