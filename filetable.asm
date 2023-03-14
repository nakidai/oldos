filetable:
    filetable_ff    db  0,  0,  6, 11, "kernel.bin", 0, 0       ; Cylinder, Head, Sector, Size, Name
                    db  0,  0, 17,  1, "calc.bin", 0, 0, 0, 0
                    db  0,  0, 18,  2, "viewer.bin", 0, 0
                    db  0,  1,  2,  1, 'null.bin', 0, 0, 0, 0
                    db  0,  1,  3,  1, "snake.bin", 0, 0, 0

times 2048-($-$$) db 0  ; 1024 bytes