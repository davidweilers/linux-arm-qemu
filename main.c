#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/fb.h>
#include <sys/mman.h>
#include <unistd.h>

int main() {
    printf("Hello, Framebuffer!\n");
    int fbfd = open("/dev/fb0", O_RDWR);
    if (fbfd == -1) {
        perror("Error: Cannot open framebuffer device");
        exit(1);
    }

    struct fb_var_screeninfo vinfo;
    if (ioctl(fbfd, FBIOGET_VSCREENINFO, &vinfo)) {
        perror("Error: Cannot get screen info");
        exit(1);
    }

    printf("Framebuffer resolution: %dx%d, %d bpp\n",
           vinfo.xres, vinfo.yres, vinfo.bits_per_pixel);

    // Map framebuffer to user memory
    long screensize = vinfo.yres_virtual * vinfo.xres_virtual * vinfo.bits_per_pixel / 8;
    char *fbp = mmap(0, screensize, PROT_READ | PROT_WRITE, MAP_SHARED, fbfd, 0);
    if ((int)fbp == -1) {
        perror("Error: Failed to map framebuffer device to memory");
        exit(1);
    }

    // Draw a red pixel at (100, 100)
    int x = 100, y = 100;
    long location = (x + vinfo.xoffset) * (vinfo.bits_per_pixel / 8) +
                    (y + vinfo.yoffset) * vinfo.xres_virtual * (vinfo.bits_per_pixel / 8);
    * (unsigned int *)(fbp + location) = 0x00FF0000; // Red color

    sleep(5); // Display for 5 seconds

    // Cleanup
    munmap(fbp, screensize);
    close(fbfd);
    return 0;
}
