MEMORY
{
    BOOT: start = $8000, size = $200, file = %O;
}

SEGMENTS {
    BOOTSECTOR: load = BOOT, start = $8000;
}
