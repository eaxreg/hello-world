default:
	uasm -win64 hello_world.s ; ld hello_world.o; 

run: default
	echo ""
	./a.out
