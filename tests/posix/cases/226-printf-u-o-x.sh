# printf %u %o %x %X and the '#' flag
printf '[%u][%o][%x][%X]\n' 42 8 255 255
printf '[%#o][%#x][%#X][%08x][%-6x]\n' 8 255 255 255 255
