#include <stdio.h>
#include <stdint.h>

uint16_t bytes_per_cluster = 8 * 512;
uint16_t bytes_per_sector = 512;

void test_fat_read_bytes(uint16_t* dest, uint16_t cluster, uint16_t offs, uint16_t len) {
	// first we need to find the cluster that the actual data is stored in
	// to do this we need to loop through the clusters until we reach the one that
	// the offset is in.

	int i;
	uint16_t cluster_offs = offs / bytes_per_cluster;
	uint16_t sector_offs = (offs % bytes_per_cluster) / bytes_per_sector;

	printf("cluster_offs: %d\n", cluster_offs);
	printf("sector_offs:  %d\n", sector_offs);



}

int main(void)
{
    uint16_t* dest = 0;
    uint16_t cluster = 0;
    uint16_t offs = 96;
    uint16_t len = 10;

    test_fat_read_bytes(dest, cluster, offs, len);

    return 0;
}