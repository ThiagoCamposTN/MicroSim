[começo]
registrador.a="1"
registrador.b="2"
registrador.pc="3"
registrador.pp="4"
registrador.aux="5"
registrador.ir="6"
registrador.ix="7"
registrador.mbr="8"
registrador.mar="9"
flag.z="1"
flag.n="2"
flag.c="3"
flag.o="4"
instrucoes=[
	"LDA #10",
	"LDB #9",
	"ABA",
	"STA 0000",
	"CAL EXIT"
]
memoria = {
    "0": "10",
    "1": "ff",
}

[fim]
registrador.a="19"
registrador.b="9"
flag.z="0"
flag.n="0"
flag.c="0"
flag.o="0"
memoria = {
    "0": "19",
	"1": "ff",
}
