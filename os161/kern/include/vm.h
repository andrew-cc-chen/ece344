#ifndef _VM_H_
#define _VM_H_

#include <machine/vm.h>
#include <synch.h>

/*
 * VM system-related definitions.
 *
 * You'll probably want to add stuff here.
 */


/* Fault-type arguments to vm_fault() */
#define VM_FAULT_READ        0    /* A read was attempted */
#define VM_FAULT_WRITE       1    /* A write was attempted */
#define VM_FAULT_READONLY    2    /* A write to a readonly page was attempted*/

struct coremap_entry {
	//each lv2 page table here:
	int kern_page;		//1 if is kern     kern page doesnt go through vmfault
	int last_page;		//1 if last page of the block
	int allocated;		//1 if allocated by a process
	int dirty;			//1 if used and need to be flushed to be reused
	int block_size;
	
	//for offset to translate between virtual and physical address
	vaddr_t vaddr;  // vaddr mapped to this ppage
	paddr_t paddr;  // paddr of this page

	//swap stuff
	pid_t pid; /////////////////not sure 666
	int tlb_index;	
	//int used;				//1 if used --- 0 means can be evicted
	//for later use
	// unsigned block_size; // size of chunk, need for free_kpages (not used by user alloc)
};

struct coremap_entry* coremap;

int coremap_size;

//int total_allocated_pages;			//allocated pages excluding coremap's 1st page

paddr_t coremap_base;

// struct semaphore* coremap_sem;


/* Initialization function */
void vm_bootstrap(void);

/* Fault handling function called by trap code */
int vm_fault(int faulttype, vaddr_t faultaddress);

/* Allocate/free kernel heap pages (called by kmalloc/kfree) */
vaddr_t alloc_kpages(int npages);
void free_kpages(vaddr_t addr);
paddr_t getppages(unsigned long npages);
void update_coremap(paddr_t paddr);

#endif /* _VM_H_ */