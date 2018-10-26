///*
// * Sample/test code for running a user program.  You can use this for
// * reference when implementing the execv() system call. Remember though
// * that execv() needs to do more than this function does.
// */
//
//#include <types.h>
//#include <kern/unistd.h>
//#include <kern/errno.h>
//#include <lib.h>
//#include <addrspace.h>
//#include <thread.h>
//#include <curthread.h>
//#include <vm.h>
//#include <vfs.h>
//#include <test.h>
//
///*
// * Load program "progname" and start running it in usermode.
// * Does not return except on error.
// *
// * Calls vfs_open on progname and thus may destroy it.
// */
//
////argc - program arguments
////argc - argument count
//
//int
//runprogram(char *progname, char **argv, int argc) {
//    struct vnode *v;
//    vaddr_t entrypoint, stackptr;
//    int result;
//    
//    // Open the file. 
//    result = vfs_open(progname, O_RDONLY, &v);
//    if (result) {
//        return result;
//    }
//
//    // We should be a new thread.
//    assert(curthread->t_vmspace == NULL);
//
//    // Create a new address space. 
//    curthread->t_vmspace = as_create();
//    if (curthread->t_vmspace == NULL) {
//        vfs_close(v);
//        return ENOMEM;
//    }
//
//    // Activate it. 
//    as_activate(curthread->t_vmspace);
//
//    // Load the executable. 
//    result = load_elf(v, &entrypoint);
//    if (result) {
//        vfs_close(v);
//        return result;
//    }
//
//    // Done with the file now. 
//    vfs_close(v);
//
//    // Define the user stack in the address space 
//    result = as_define_stack(curthread->t_vmspace, &stackptr);
//    if (result) {
//        return result;
//    }
//
//    //now push user arguments onto the stack
//    int argv_addr[argc];
//    int i;
//    //        int argLength = 0;
//    int spOffset = 0;
//    int argument_size = 0;
//    for (i = 0; i < argc; i++) {
//
//        // if (strlen(argv[i]) % 4 > 0) {
//
//        // }
//        //            argLength = str(argc)
//        
//        argument_size = (strlen(argv[i]) + 1);
//        spOffset = (argument_size + 3)/4;
//        stackptr -= spOffset*4;
//        
////        stackptr -= (strlen(argv[i]) + 1); //1 at the end for null end
////        if(stackptr%4 != 0){
////            stackptr -= ;
////        }
//        result = copyoutstr(argv[i], stackptr, strlen(argv[i]) + 1, NULL);
//        if (result) { //should return 0
//            return result;
//        }
//        
//        //save argument addr
//        argv_addr[i] = stackptr;
//    }
//
//    //byte alignment
////    stackptr -= stackptr % 4;
//    //shift stackptr up
////    stackptr -= 4 * (argc + 1);
//    //temp stackptr
//    int tstackptr = stackptr;
//    //will use this sp later for kernel->user
//    int argv_stackptr = stackptr;
//
//    //now push argument addresses onto the stack
//    for (i = 0; i < argc; i++) {
//        //copy 
//        result = copyout(&argv_addr[i], tstackptr, sizeof (int));
//        
//        if (result)
//            return result;
//
//        // move down to next space
//        tstackptr += 4;
//    }
//
//    //now put null at the end to signal end
//    int x = 0;
//    result = copyout(&x, tstackptr, sizeof (int));
//    if (result)
//        return result;
//
//    // Warp to user mode. 
//    md_usermode(argc, argv_stackptr,
//            stackptr, entrypoint);
//
//    // md_usermode does not return 
//    panic("md_usermode returned\n");
//    return EINVAL;
//}

/*
 * Sample/test code for running a user program.  You can use this for
 * reference when implementing the execv() system call. Remember though
 * that execv() needs to do more than this function does.
 */

#include <types.h>
#include <kern/unistd.h>
#include <kern/errno.h>
#include <lib.h>
#include <addrspace.h>
#include <thread.h>
#include <curthread.h>
#include <vm.h>
#include <vfs.h>
#include <test.h>

/*
 * Load program "progname" and start running it in usermode.
 * Does not return except on error.
 *
 * Calls vfs_open on progname and thus may destroy it.
 */

//argc - program arguments
//argc - argument count

int
runprogram(char *progname, char **argv, int argc)
{
	struct vnode *v;
	vaddr_t entrypoint, stackptr;
	int result;
        
        char* temp_name = kstrdup(progname);

	// Open the file. 
	result = vfs_open(progname, O_RDONLY, &v);
	if (result) {
		return result;
	}

	// We should be a new thread.
	assert(curthread->t_vmspace == NULL);

	// Create a new address space. 
	curthread->t_vmspace = as_create(temp_name);//to passs the name in
	if (curthread->t_vmspace==NULL) {
		vfs_close(v);
		return ENOMEM;
	}

	// Activate it. 
	as_activate(curthread->t_vmspace);

	// Load the executable. 
	result = load_elf(v, &entrypoint);
	if (result) {
		vfs_close(v);
		return result;
	}

	// Done with the file now. 
	vfs_close(v);

	// Define the user stack in the address space 
	result = as_define_stack(curthread->t_vmspace, &stackptr);
	if (result) {
		return result;
    }

	//now push user arguments onto the stack
	int argv_addr[argc];
	int i;
	for (i = 0; i < argc; i++) {
        stackptr -= strlen(argv[i]) + 1;        //1 at the end for null end

		result = copyoutstr(argv[i], stackptr, strlen(argv[i]) + 1, NULL);
		if (result)	{	//should return 0
			return result;
        }

        //save argument addr
        argv_addr[i] = stackptr;
	}

	//byte alignment
	stackptr -= stackptr % 4;
	//shift stackptr up
	stackptr -= 4*(argc + 1);
	//temp stackptr
	int tstackptr = stackptr;
	//will use this sp later for kernel->user
	int argv_stackptr = stackptr;

	//now push argument addresses onto the stack
	for (i = 0; i < argc; i++) {
		//copy 
		result = copyout(&argv_addr[i], tstackptr, sizeof(int));
		
		if(result)
			return result;

		// move down to next space
		tstackptr += 4;
	}

	//now put null at the end to signal end
    int x = 0;
	result = copyout(&x, tstackptr, sizeof(int));
	if (result)
		return result;

	// Warp to user mode. 
	md_usermode(argc, argv_stackptr,
		    stackptr, entrypoint);
	
	// md_usermode does not return 
	panic("md_usermode returned\n");
	return EINVAL;
}