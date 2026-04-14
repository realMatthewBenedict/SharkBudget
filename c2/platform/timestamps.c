#include <stdlib.h>
#include <time.h>

static time_t current_month_start(void) {
    time_t now = time(NULL);
    struct tm tm = *localtime(&now);

    tm.tm_mday = 1;
    tm.tm_hour = 0;
    tm.tm_min  = 0;
    tm.tm_sec  = 0;

    return mktime(&tm);
}

static time_t prev_month_start(int tm_mon) {
    time_t current = current_month_start();
    struct tm tm = *localtime(&current);

    tm_mon = (tm_mon + 12) % 12;
    if (tm_mon >= tm.tm_mon) {
        tm.tm_year -= 1;
    }
    tm.tm_mon = tm_mon;

    return mktime(&tm);
}

static void reverse_array(int64_t arr[], size_t n) {
    for (size_t i = 0; i < n / 2; i++) {
        size_t j = n - 1 - i;
        int64_t temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

int64_t* construct_timestamps(int num_timestamps) {
    int64_t* timestamps = malloc(num_timestamps * sizeof(int64_t));
    timestamps[0] = current_month_start();
    int j = localtime(&timestamps[0])->tm_mon;
    for (int i = 1; i < num_timestamps; ++i) {
        timestamps[i] = prev_month_start(j - i);
    }
    reverse_array(timestamps, num_timestamps);
    return timestamps;
}